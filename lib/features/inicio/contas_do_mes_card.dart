import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/data.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../data/servicos/servico_cartao.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';
import '../../domain/resumo_mes.dart';
import '../cartoes/pagar_fatura.dart';
import '../lancamentos/lancamento_acoes.dart';
import '../lancamentos/linha_conta.dart';
import '../lancamentos/pendentes_secao.dart';

/// "Contas do mês": faturas e contas fixas que vencem no mês — pago × falta
/// pagar, com atalho para pagar.
class ContasDoMesCard extends ConsumerWidget {
  const ContasDoMesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contas = ref.watch(contasDoMesProvider);
    final resumo = resumirContasDoMes(contas);
    final tema = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contas do mês',
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (contas.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Nenhuma conta ou fatura vence neste mês.',
                  style: tema.textTheme.bodyMedium
                      ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(child: _Total('Pago', resumo.pago, context.coresLastro.positivo)),
                  Expanded(child: _Total('Falta pagar', resumo.falta, tema.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: resumo.percentualPago,
                  minHeight: 8,
                  color: context.coresLastro.positivo,
                ),
              ),
              const SizedBox(height: 8),
              for (final c in contas) _Linha(conta: c),
            ],
          ],
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.rotulo, this.valor, this.cor);
  final String rotulo;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo,
            style: tema.textTheme.labelMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
        ValorMonetario(valor,
            estilo: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: cor)),
      ],
    );
  }
}

class _Linha extends ConsumerWidget {
  const _Linha({required this.conta});
  final ContaDoMes conta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final atrasada = !conta.paga && conta.vencimento.isBefore(soData(DateTime.now()));
    final cor = conta.paga
        ? cores.positivo
        : atrasada
            ? cores.negativo
            : tema.colorScheme.onSurfaceVariant;

    return LinhaConta(
      leading: Icon(
        conta.paga ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: cor,
      ),
      titulo: conta.descricao,
      riscado: conta.paga,
      subtitulo: conta.paga
          ? 'Paga · venc. ${FormatoData.dia(conta.vencimento)}'
          : atrasada
              ? 'Atrasada · venceu ${FormatoData.dia(conta.vencimento)}'
              : 'Vence ${FormatoData.dia(conta.vencimento)}',
      corSubtitulo: atrasada ? cores.negativo : null,
      valor: ValorMonetario(conta.valor,
          estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      acao: !conta.paga && conta.podePagar ? 'Pagar' : null,
      onAcao: () => _pagar(context, ref),
    );
  }

  Future<void> _pagar(BuildContext context, WidgetRef ref) async {
    final id = conta.referenciaId;
    if (id == null) return;
    final dao = ref.read(bancoProvider);
    if (conta.ehFatura) {
      final fatura = await dao.cartoesDao.faturaPorId(id);
      if (fatura == null) return;
      final cartao = await dao.cartoesDao.obter(fatura.cartaoId);
      if (cartao == null || !context.mounted) return;
      await pagarFaturaDialog(context, ref, cartao, fatura, conta.valor);
      return;
    }
    final o = await dao.compromissosDao.ocorrencia(id);
    if (o == null) return;
    final c = await dao.compromissosDao.compromisso(o.compromissoId);
    if (c == null || !context.mounted) return;
    int? contaId = c.contaId;
    int? valor;
    if (contaId == null) {
      final r = await dialogoConfirmacao(
        context,
        ref,
        titulo: 'Pagar ${c.descricao}',
        rotulo: 'Pagar',
        valorInicial: o.valor,
      );
      if (r == null) return;
      contaId = r.contaId;
      valor = r.valor;
    }
    try {
      await ref
          .read(servicoCompromissoProvider)
          .pagarOcorrencia(o, contaId: contaId, valor: valor);
      if (context.mounted) mostrarAviso(context, 'Pagamento registrado');
    } on OperacaoInvalida catch (e) {
      if (context.mounted) mostrarAviso(context, e.mensagem);
    }
  }
}
