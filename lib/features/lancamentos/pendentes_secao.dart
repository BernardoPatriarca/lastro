import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/campo_valor.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/servicos/servico_cartao.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';
import 'lancamento_acoes.dart';

/// "Pendentes": receitas previstas a confirmar e contas fixas a pagar, com
/// ação de um toque (tocar na linha permite ajustar valor e conta). Mostra as
/// 3 primeiras; o resto fica atrás de "Ver todas".
class PendentesSecao extends ConsumerStatefulWidget {
  const PendentesSecao({super.key});

  static const visiveis = 3;

  @override
  ConsumerState<PendentesSecao> createState() => _PendentesSecaoState();
}

class _PendentesSecaoState extends ConsumerState<PendentesSecao> {
  bool _todas = false;

  @override
  Widget build(BuildContext context) {
    final ocorrencias = ref.watch(ocorrenciasPendentesProvider);
    final receitas = ref.watch(receitasPendentesProvider);
    final total = ocorrencias.length + receitas.length;
    if (total == 0) return const SizedBox.shrink();
    final tema = Theme.of(context);

    // Receitas primeiro (dinheiro entrando), depois as contas por vencimento.
    final linhas = <Widget>[
      for (final r in receitas) _LinhaReceita(receita: r),
      for (final o in ocorrencias) _LinhaOcorrencia(ocorrencia: o),
    ];
    final mostradas = _todas ? linhas : linhas.take(PendentesSecao.visiveis).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Icon(Icons.pending_actions_rounded, color: tema.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text('Pendentes',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Badge(label: Text('$total')),
                ],
              ),
            ),
            ...mostradas,
            if (total > PendentesSecao.visiveis)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _todas = !_todas),
                  icon: Icon(_todas ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  label: Text(_todas
                      ? 'Mostrar menos'
                      : 'Ver todas (${total - PendentesSecao.visiveis} a mais)'),
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _LinhaOcorrencia extends ConsumerWidget {
  const _LinhaOcorrencia({required this.ocorrencia});
  final OcorrenciaCompromisso ocorrencia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final c = ref.watch(compromissosPorIdProvider)[ocorrencia.compromissoId];
    if (c == null) return const SizedBox.shrink();
    final hoje = soData(DateTime.now());
    final atrasada = ocorrencia.dataVencimento.isBefore(hoje);
    final dias = hoje.difference(ocorrencia.dataVencimento).inDays;
    final sufixo = c.numeroParcelas == null || ocorrencia.numeroParcela == null
        ? ''
        : ' (${ocorrencia.numeroParcela}/${c.numeroParcelas})';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(Icons.receipt_long_rounded,
          color: atrasada ? context.coresLastro.negativo : tema.colorScheme.onSurfaceVariant),
      title: Text('${c.descricao}$sufixo', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        atrasada
            ? 'Venceu ${FormatoData.dia(ocorrencia.dataVencimento).substring(0, 5)} · $dias ${dias == 1 ? 'dia' : 'dias'} de atraso'
            : 'Vence ${FormatoData.dia(ocorrencia.dataVencimento)}',
        style: TextStyle(color: atrasada ? context.coresLastro.negativo : null),
      ),
      onTap: () => _pagar(context, ref, c, ajustar: true),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValorMonetario(ocorrencia.valor,
              estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 14)),
            onPressed: () => _pagar(context, ref, c, ajustar: false),
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }

  Future<void> _pagar(BuildContext context, WidgetRef ref, Compromisso c,
      {required bool ajustar}) async {
    final servico = ref.read(servicoCompromissoProvider);
    int? valor;
    int? contaId = c.contaId;
    // Sem conta definida, ou ao tocar na linha, pergunta antes.
    if (ajustar || contaId == null) {
      final r = await dialogoConfirmacao(
        context,
        ref,
        titulo: 'Pagar ${c.descricao}',
        rotulo: 'Pagar',
        valorInicial: ocorrencia.valor,
        contaInicial: contaId,
      );
      if (r == null) return;
      valor = r.valor;
      contaId = r.contaId;
    }
    try {
      await servico.pagarOcorrencia(ocorrencia, contaId: contaId, valor: valor);
      if (context.mounted) mostrarAviso(context, 'Pagamento registrado');
    } on OperacaoInvalida catch (e) {
      if (context.mounted) mostrarAviso(context, e.mensagem);
    }
  }
}

class _LinhaReceita extends ConsumerWidget {
  const _LinhaReceita({required this.receita});
  final ReceitaRecorrente receita;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(Icons.south_west_rounded, color: context.coresLastro.positivo),
      title: Text(receita.descricao, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('Prevista para o dia ${receita.diaPrevisto}'),
      onTap: () => _confirmar(context, ref, ajustar: true),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValorMonetario(receita.valorPrevisto,
              colorirPorSinal: true,
              estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 14)),
            onPressed: () => _confirmar(context, ref, ajustar: false),
            child: const Text('Receber'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmar(BuildContext context, WidgetRef ref, {required bool ajustar}) async {
    int? valor;
    int? contaId;
    if (ajustar) {
      final r = await dialogoConfirmacao(
        context,
        ref,
        titulo: 'Confirmar ${receita.descricao}',
        rotulo: 'Confirmar',
        valorInicial: receita.valorPrevisto,
        contaInicial: receita.contaId,
      );
      if (r == null) return;
      valor = r.valor;
      contaId = r.contaId;
    }
    await ref
        .read(servicoCompromissoProvider)
        .confirmarReceita(receita, valor: valor, contaId: contaId);
    if (context.mounted) mostrarAviso(context, 'Receita confirmada');
  }
}

class RespostaConfirmacao {
  const RespostaConfirmacao(this.valor, this.contaId);
  final int valor;
  final int contaId;
}

/// Pede o valor (ajustável) e a conta antes de pagar/confirmar.
Future<RespostaConfirmacao?> dialogoConfirmacao(
  BuildContext context,
  WidgetRef ref, {
  required String titulo,
  required String rotulo,
  required int valorInicial,
  int? contaInicial,
}) async {
  final contas = ref.read(contasAtivasProvider);
  if (contas.isEmpty) {
    mostrarAviso(context, 'Cadastre uma conta primeiro.');
    return null;
  }
  final valor = ControladorValor(centavos: valorInicial);
  var contaId = contas.any((c) => c.id == contaInicial) ? contaInicial! : contas.first.id;
  final r = await showDialog<RespostaConfirmacao>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) => AlertDialog(
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CampoValor(controller: valor, autofocus: true),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: contaId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Conta'),
              items: [for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome))],
              onChanged: (v) => setSt(() => contaId = v!),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Previsto: ${Moeda.formatar(valorInicial)}',
                  style: Theme.of(ctx).textTheme.bodySmall),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () {
              if (valor.centavos <= 0) return;
              Navigator.pop(ctx, RespostaConfirmacao(valor.centavos, contaId));
            },
            child: Text(rotulo),
          ),
        ],
      ),
    ),
  );
  descartarDepoisDoDialogo([valor]);
  return r;
}
