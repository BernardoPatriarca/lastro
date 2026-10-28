import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/estado_vazio.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/competencia.dart';
import '../../domain/enums.dart';
import '../../domain/fatura.dart';
import '../lancamentos/lancamento_acoes.dart';
import 'cartao_visual.dart';
import 'pagar_fatura.dart';

/// Detalhe do cartão: fatura atual (e navegação para as futuras/passadas),
/// lançamentos e parcelas, datas e botão "Pagar fatura".
class CartaoDetalhePage extends ConsumerStatefulWidget {
  const CartaoDetalhePage({super.key, required this.id});
  final int id;

  @override
  ConsumerState<CartaoDetalhePage> createState() => _CartaoDetalhePageState();
}

class _CartaoDetalhePageState extends ConsumerState<CartaoDetalhePage> {
  Competencia? _comp;

  @override
  Widget build(BuildContext context) {
    final resumo = ref
        .watch(resumosCartaoProvider)
        .where((r) => r.cartao.id == widget.id)
        .firstOrNull;
    if (resumo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ref.watch(cartoesProvider).hasValue
            ? const EstadoVazio(
                icone: Icons.credit_card_off_rounded,
                titulo: 'Cartão não encontrado',
              )
            : const SizedBox.shrink(),
      );
    }

    final cartao = resumo.cartao;
    final faturas = [
      for (final f in ref.watch(faturasProvider).ou)
        if (f.cartaoId == cartao.id) f,
    ];
    final totais = ref.watch(totaisFaturasProvider);
    final atual = resumo.ciclo.competencia;
    final comp = _comp ?? atual;

    // Limites da navegação: da fatura mais antiga até a mais distante.
    final comps = [for (final f in faturas) Competencia.parse(f.competencia)]..sort();
    final minimo = comps.isEmpty || atual < comps.first ? atual : comps.first;
    final maximo = comps.isEmpty || atual.somarMeses(1) > comps.last
        ? atual.somarMeses(1)
        : comps.last;

    final ciclo = cicloDaCompetencia(
      comp,
      diaFechamento: cartao.diaFechamento,
      diaVencimento: cartao.diaVencimento,
    );
    final fatura = faturas.where((f) => f.competencia == comp.chave).firstOrNull;
    final total = fatura == null ? 0 : (totais[fatura.id] ?? 0);
    final status = fatura == null
        ? statusEfetivo(StatusFatura.aberta, ciclo.dataFechamento, DateTime.now())
        : (fatura.status == StatusFatura.paga
            ? StatusFatura.paga
            : statusEfetivo(StatusFatura.aberta, fatura.dataFechamento, DateTime.now()));
    final lancs = fatura == null
        ? const <Lancamento>[]
        : [
            for (final l in ref.watch(lancamentosProvider).ou)
              if (l.faturaId == fatura.id) l,
          ];

    final proximas = [
      for (var i = 1; i <= 12; i++)
        if (faturas.any((f) =>
            f.competencia == comp.somarMeses(i).chave &&
            (totais[f.id] ?? 0) > 0))
          faturas.firstWhere((f) => f.competencia == comp.somarMeses(i).chave),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(cartao.nome),
        actions: [
          IconButton(
            tooltip: 'Editar cartão',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Rotas.editarCartao(cartao.id)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        children: [
          CartaoVisual(resumo: resumo),
          const SizedBox(height: 20),
          _NavegadorFatura(
            comp: comp,
            status: status,
            podeVoltar: comp > minimo,
            podeAvancar: comp < maximo,
            onVoltar: () => setState(() => _comp = comp.somarMeses(-1)),
            onAvancar: () => setState(() => _comp = comp.somarMeses(1)),
            onHoje: () => setState(() => _comp = null),
          ),
          const SizedBox(height: 12),
          _ResumoFatura(
            total: total,
            ciclo: ciclo,
            status: status,
            fatura: fatura,
            onPagar: fatura == null || status == StatusFatura.paga || total <= 0
                ? null
                : () => pagarFaturaDialog(context, ref, cartao, fatura, total),
          ),
          if (proximas.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Comprometido nas próximas faturas',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: proximas.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final f = proximas[i];
                  final c = Competencia.parse(f.competencia);
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _comp = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _mesCurto(c),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          ValorMonetario(
                            totais[f.id] ?? 0,
                            estilo: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Lançamentos da fatura',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (lancs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: EstadoVazio(
                icone: Icons.receipt_long_rounded,
                titulo: 'Nenhuma compra nesta fatura',
                mensagem: 'Toque em + e escolha "Crédito" para lançar uma compra.',
              ),
            )
          else
            for (final l in lancs)
              LinhaLancamentoDispensavel(key: ValueKey(l.id), lancamento: l),
        ],
      ),
    );
  }

  static String _mesCurto(Competencia c) {
    const nomes = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${nomes[c.mes - 1]}/${c.ano % 100}';
  }
}

class _NavegadorFatura extends StatelessWidget {
  const _NavegadorFatura({
    required this.comp,
    required this.status,
    required this.podeVoltar,
    required this.podeAvancar,
    required this.onVoltar,
    required this.onAvancar,
    required this.onHoje,
  });
  final Competencia comp;
  final StatusFatura status;
  final bool podeVoltar;
  final bool podeAvancar;
  final VoidCallback onVoltar;
  final VoidCallback onAvancar;
  final VoidCallback onHoje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: 'Fatura anterior',
          onPressed: podeVoltar ? onVoltar : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onHoje,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Text('Fatura de ${FormatoData.mesAno(comp.primeiroDia)}',
                      style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  _ChipStatus(status),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Próxima fatura',
          onPressed: podeAvancar ? onAvancar : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _ChipStatus extends StatelessWidget {
  const _ChipStatus(this.status);
  final StatusFatura status;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final (texto, cor, icone) = switch (status) {
      StatusFatura.aberta => ('Aberta', tema.colorScheme.secondary, Icons.lock_open_rounded),
      StatusFatura.fechada => ('Fechada', const Color(0xFFF59E0B), Icons.lock_rounded),
      StatusFatura.paga => ('Paga', const Color(0xFF22C55E), Icons.check_circle_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 5),
          Text(texto, style: TextStyle(color: cor, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ResumoFatura extends StatelessWidget {
  const _ResumoFatura({
    required this.total,
    required this.ciclo,
    required this.status,
    required this.fatura,
    required this.onPagar,
  });
  final int total;
  final CicloFatura ciclo;
  final StatusFatura status;
  final Fatura? fatura;
  final VoidCallback? onPagar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total da fatura',
                style: tema.textTheme.labelLarge?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            ValorMonetario(total,
                estilo: tema.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _Dado('Fecha em', FormatoData.dia(ciclo.dataFechamento))),
                Expanded(child: _Dado('Vence em', FormatoData.dia(ciclo.dataVencimento))),
                if (fatura?.dataPagamento != null)
                  Expanded(child: _Dado('Paga em', FormatoData.dia(fatura!.dataPagamento!))),
              ],
            ),
            if (status != StatusFatura.paga) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onPagar,
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Pagar fatura'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  const _Dado(this.rotulo, this.valor);
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo,
            style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
        Text(valor, style: tema.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
