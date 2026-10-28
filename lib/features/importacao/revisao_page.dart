import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/icones.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/campo_valor.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/categorizacao.dart';
import '../../domain/enums.dart';
import '../categorias/seletor_categoria.dart';
import '../lancamentos/lancamento_acoes.dart';
import 'importacao_controller.dart';

/// Revisão antes de confirmar: cada transação com data, descrição, valor e
/// categoria sugerida; dá para ignorar linhas, trocar a categoria (e criar
/// regra) e ver duplicadas e contas fixas parecidas.
class RevisaoImportacaoPage extends ConsumerStatefulWidget {
  const RevisaoImportacaoPage({super.key});

  @override
  ConsumerState<RevisaoImportacaoPage> createState() => _RevisaoState();
}

class _RevisaoState extends ConsumerState<RevisaoImportacaoPage> {
  bool _importando = false;

  Future<void> _trocarCategoria(int i) async {
    final estado = ref.read(importacaoProvider);
    final linha = estado.linhas[i];
    final tipo = linha.transacao.ehSaida ? TipoCategoria.gasto : TipoCategoria.ganho;
    final escolhida = await escolherCategoria(context, ref, tipo, incluirNenhuma: true);
    if (escolhida == null || !mounted) return;
    final novoId = escolhida == 0 ? null : escolhida;
    final antes = linha.categoriaId;
    ref.read(importacaoProvider.notifier).definirCategoria(i, novoId);
    if (novoId == null || novoId == antes) return;

    // Ao corrigir a categoria, oferece criar uma regra para as próximas vezes.
    final padrao = sugerirPadrao(linha.transacao.descricao);
    final categoria = ref.read(categoriasPorIdProvider)[novoId];
    if (padrao.isEmpty || categoria == null) return;
    final controlador = TextEditingController(text: padrao);
    final criar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Criar regra?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrições que contêm o texto abaixo passam a ir para '
                '"${categoria.nome}" automaticamente.'),
            const SizedBox(height: 12),
            TextField(
              controller: controlador,
              decoration: const InputDecoration(labelText: 'Descrições com'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Agora não')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Criar regra'),
          ),
        ],
      ),
    );
    final texto = controlador.text.trim();
    descartarDepoisDoDialogo([controlador]);
    if (criar != true || texto.isEmpty || !mounted) return;
    await ref.read(bancoProvider).categoriasDao.inserirRegra(
          RegrasCategorizacaoCompanion.insert(padrao: texto, categoriaId: novoId),
        );
    await ref.read(importacaoProvider.notifier).reaplicarRegras();
  }

  Future<void> _importar() async {
    final estado = ref.read(importacaoProvider);
    if (estado.selecionadas == 0) {
      mostrarAviso(context, 'Marque pelo menos uma transação para importar.');
      return;
    }
    final servico = ref.read(servicoImportacaoProvider);
    final eraPrimeira = estado.destino == TipoDestino.conta &&
        await servico.importadosDaConta(estado.contaId!) == 0;

    setState(() => _importando = true);
    final resumo = await ref.read(importacaoProvider.notifier).confirmar();
    if (!mounted) return;
    setState(() => _importando = false);

    final partes = [
      '${resumo.importadas} lançamentos importados',
      if (resumo.vinculadas > 0) '${resumo.vinculadas} contas fixas marcadas como pagas',
      if (resumo.ignoradas > 0) '${resumo.ignoradas} entradas ignoradas',
    ];
    mostrarAviso(context, partes.join(' · '));

    if (eraPrimeira) {
      await _oferecerAjusteDeSaldoInicial(estado);
    }
    ref.read(importacaoProvider.notifier).limpar();
    if (mounted) context.go(Rotas.mais);
  }

  /// Após a primeira importação, oferece "Ajustar saldo inicial" para o saldo
  /// do app bater com o do banco.
  Future<void> _oferecerAjusteDeSaldoInicial(EstadoImportacao estado) async {
    final conta = await ref.read(bancoProvider).contasDao.obter(estado.contaId!);
    if (conta == null || !mounted) return;
    final servico = ref.read(servicoImportacaoProvider);
    final saldoApp = await servico.saldoAtual(conta);
    if (!mounted) return;

    final valor = ControladorValor(centavos: (estado.saldoBanco ?? 0).abs());
    var negativo = (estado.saldoBanco ?? 0) < 0;
    final real = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Ajustar saldo inicial?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Depois da importação, o saldo da conta "${conta.nome}" no app é '
                    '${Moeda.formatar(saldoApp)}.'),
                const SizedBox(height: 8),
                Text(
                  estado.saldoBanco != null
                      ? 'O extrato informa saldo de ${Moeda.formatar(estado.saldoBanco!)}'
                          '${estado.dataSaldoBanco != null ? ' em ${FormatoData.dia(estado.dataSaldoBanco!)}' : ''}.'
                      : 'Informe o saldo real que está no banco.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                CampoValor(controller: valor, rotulo: 'Saldo real no banco'),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: negativo,
                  onChanged: (v) => setSt(() => negativo = v ?? false),
                  title: const Text('Saldo negativo'),
                ),
                Text(
                  'Eu mudo o saldo inicial da conta para o saldo do app bater com o do banco.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Agora não')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
              onPressed: () =>
                  Navigator.pop(ctx, negativo ? -valor.centavos : valor.centavos),
              child: const Text('Ajustar'),
            ),
          ],
        ),
      ),
    );
    descartarDepoisDoDialogo([valor]);
    if (real == null) return;
    await ref.read(servicoLancamentosProvider).ajustarSaldoInicial(
          conta: conta,
          saldoReal: real,
          saldoAtual: saldoApp,
        );
    if (mounted) mostrarAviso(context, 'Saldo inicial ajustado');
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(importacaoProvider);
    final ctl = ref.read(importacaoProvider.notifier);
    final tema = Theme.of(context);
    final categorias = ref.watch(categoriasPorIdProvider);
    final ocorrencias = ref.watch(ocorrenciasProvider).ou;
    final compromissos = ref.watch(compromissosPorIdProvider);

    if (estado.linhas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revisar importação')),
        body: const Center(child: Text('Nada para revisar. Escolha um arquivo.')),
      );
    }

    final todasMarcadas = estado.linhas.every(
      (l) => l.selecionada || (estado.destino == TipoDestino.cartao && !l.transacao.ehSaida),
    );
    var entradas = 0, saidas = 0;
    for (final l in estado.linhas) {
      if (!l.selecionada) continue;
      if (l.transacao.ehSaida) {
        saidas += l.transacao.valor;
      } else {
        entradas += l.transacao.valor;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar importação'),
        actions: [
          TextButton(
            onPressed: () => ctl.selecionarTodas(!todasMarcadas),
            child: Text(todasMarcadas ? 'Desmarcar todas' : 'Marcar todas'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tema.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${estado.selecionadas} de ${estado.linhas.length} selecionadas'
                    '${estado.duplicadas > 0 ? ' · ${estado.duplicadas} já importadas' : ''}',
                    style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Entradas', style: tema.textTheme.bodySmall),
                      ),
                      ValorMonetario(entradas, colorirPorSinal: true, mostrarMais: true),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Saídas', style: tema.textTheme.bodySmall)),
                      ValorMonetario(saidas, colorirPorSinal: true, mostrarMais: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: estado.linhas.length,
              itemBuilder: (context, i) {
                final l = estado.linhas[i];
                final t = l.transacao;
                final categoria = l.categoriaId == null ? null : categorias[l.categoriaId];
                final oc = l.ocorrenciaId == null
                    ? null
                    : ocorrencias.where((o) => o.id == l.ocorrenciaId).firstOrNull;
                final comp = oc == null ? null : compromissos[oc.compromissoId];

                return Opacity(
                  opacity: l.selecionada ? 1 : 0.55,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 14, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: l.selecionada,
                                  onChanged: (_) => ctl.alternar(i),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t.descricao.isEmpty ? '(sem descrição)' : t.descricao,
                                            maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(FormatoData.dia(t.data),
                                            style: tema.textTheme.bodySmall?.copyWith(
                                                color: tema.colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ValorMonetario(
                                    t.valor,
                                    colorirPorSinal: true,
                                    mostrarMais: true,
                                    estilo: tema.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 2),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ActionChip(
                                    avatar: categoria == null
                                        ? const Icon(Icons.sell_outlined, size: 18)
                                        : Icon(iconeDaCategoria(categoria), size: 18,
                                            color: Color(categoria.cor)),
                                    label: Text(categoria?.nome ?? 'Sem categoria'),
                                    onPressed: () => _trocarCategoria(i),
                                  ),
                                  if (l.duplicada)
                                    Chip(
                                      avatar: Icon(Icons.copy_all_rounded, size: 16,
                                          color: context.coresLastro.alerta),
                                      label: const Text('Já importada'),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ),
                            if (comp != null && oc != null)
                              SwitchListTile(
                                contentPadding: const EdgeInsets.only(left: 12),
                                dense: true,
                                value: l.usarOcorrencia,
                                onChanged: (_) => ctl.alternarOcorrencia(i),
                                title: Text('Marcar "${comp.descricao}" como paga'),
                                subtitle: Text(
                                  'Parece a conta que vence em ${FormatoData.dia(oc.dataVencimento)}: '
                                  'em vez de criar um gasto novo.',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            decoration: BoxDecoration(
              color: tema.colorScheme.surface,
              border: Border(top: BorderSide(color: tema.colorScheme.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              top: false,
              child: FilledButton(
                onPressed: _importando || estado.selecionadas == 0 ? null : _importar,
                child: _importando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text('Importar ${estado.selecionadas} '
                        '${estado.selecionadas == 1 ? 'lançamento' : 'lançamentos'}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData iconeDaCategoria(Categoria c) => iconeDeChave(c.icone);
