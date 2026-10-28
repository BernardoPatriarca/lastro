import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/servicos/servico_cartao.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';
import '../lancamentos/lancamento_acoes.dart';

enum AcaoInvestimento { aporte, resgate, atualizarSaldo }

/// Diálogo de aporte, resgate ou "atualizar saldo" de um investimento.
Future<void> abrirMovimentoInvestimento(
  BuildContext context,
  WidgetRef ref,
  Investimento investimento,
  AcaoInvestimento acao, {
  int saldoAtual = 0,
}) async {
  final contas = ref.read(contasAtivasProvider);
  if (acao != AcaoInvestimento.atualizarSaldo && contas.isEmpty) {
    mostrarAviso(context, 'Cadastre uma conta para aportar ou resgatar.');
    return;
  }
  final valor = ControladorValor(
    centavos: acao == AcaoInvestimento.atualizarSaldo ? saldoAtual : 0,
  );
  var contaId = contas.isNotEmpty ? contas.first.id : 0;
  var data = soData(DateTime.now());

  final titulo = switch (acao) {
    AcaoInvestimento.aporte => 'Aportar em ${investimento.nome}',
    AcaoInvestimento.resgate => 'Resgatar de ${investimento.nome}',
    AcaoInvestimento.atualizarSaldo => 'Atualizar saldo',
  };
  final rotulo = switch (acao) {
    AcaoInvestimento.atualizarSaldo => 'Quanto vale hoje?',
    _ => 'Valor',
  };

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) => AlertDialog(
        title: Text(titulo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (acao == AcaoInvestimento.atualizarSaldo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Informe o saldo total que o investimento tem agora (com os '
                    'rendimentos). Saldo atual no app: ${Moeda.formatar(saldoAtual)}.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ),
              CampoValor(controller: valor, rotulo: rotulo, autofocus: true),
              if (acao != AcaoInvestimento.atualizarSaldo) ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: contaId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: acao == AcaoInvestimento.aporte ? 'Sai da conta' : 'Cai na conta',
                  ),
                  items: [
                    for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome)),
                  ],
                  onChanged: (v) => setSt(() => contaId = v!),
                ),
              ],
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_rounded),
                title: const Text('Data'),
                subtitle: Text(FormatoData.dia(data)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setSt(() => data = soData(d));
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () {
              if (valor.centavos <= 0 && acao != AcaoInvestimento.atualizarSaldo) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ),
  );
  final centavos = valor.centavos;
  descartarDepoisDoDialogo([valor]);
  if (ok != true || !context.mounted) return;

  final servico = ref.read(servicoInvestimentoProvider);
  try {
    switch (acao) {
      case AcaoInvestimento.aporte:
        await servico.aportar(
          contaId: contaId, valor: centavos, data: data, investimentoId: investimento.id,
          descricao: 'Aporte em ${investimento.nome}',
        );
      case AcaoInvestimento.resgate:
        await servico.resgatar(
          contaId: contaId, valor: centavos, data: data, investimentoId: investimento.id,
          descricao: 'Resgate de ${investimento.nome}',
        );
      case AcaoInvestimento.atualizarSaldo:
        await servico.atualizarSaldo(
          investimentoId: investimento.id, saldo: centavos, data: data,
        );
    }
    if (context.mounted) mostrarAviso(context, 'Registrado');
  } on OperacaoInvalida catch (e) {
    if (context.mounted) mostrarAviso(context, e.mensagem);
  }
}
