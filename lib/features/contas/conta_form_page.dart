import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/providers.dart';
import '../../domain/datas.dart';
import '../../domain/enums.dart';

/// Cadastro e edição de conta.
class ContaFormPage extends ConsumerStatefulWidget {
  const ContaFormPage({super.key, this.id});
  final int? id;

  @override
  ConsumerState<ContaFormPage> createState() => _ContaFormPageState();
}

class _ContaFormPageState extends ConsumerState<ContaFormPage> {
  final _chave = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _saldo = ControladorValor();

  Conta? _original;
  bool _carregando = false;
  TipoConta _tipo = TipoConta.corrente;
  bool _negativo = false;
  DateTime _dataSaldo = soData(DateTime.now());
  bool _creditoSeguro = true;
  bool _ativa = true;

  bool get _edicao => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (_edicao) {
      _carregando = true;
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final c = await ref.read(bancoProvider).contasDao.obter(widget.id!);
    if (!mounted) return;
    if (c == null) {
      context.pop();
      return;
    }
    setState(() {
      _original = c;
      _carregando = false;
      _nome.text = c.nome;
      _tipo = c.tipo;
      _negativo = c.saldoInicial < 0;
      _saldo.centavos = c.saldoInicial.abs();
      _dataSaldo = c.dataSaldoInicial;
      _creditoSeguro = c.considerarNoCreditoSeguro;
      _ativa = c.ativa;
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    _saldo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final dao = ref.read(bancoProvider).contasDao;
    final saldo = _negativo ? -_saldo.centavos : _saldo.centavos;
    final original = _original;
    if (original == null) {
      await dao.inserir(ContasCompanion.insert(
        nome: _nome.text.trim(),
        tipo: _tipo,
        dataSaldoInicial: _dataSaldo,
        saldoInicial: Value(saldo),
        considerarNoCreditoSeguro: Value(_creditoSeguro),
      ));
    } else {
      await dao.atualizar(original.copyWith(
        nome: _nome.text.trim(),
        tipo: _tipo,
        saldoInicial: saldo,
        dataSaldoInicial: _dataSaldo,
        considerarNoCreditoSeguro: _creditoSeguro,
        ativa: _ativa,
      ));
    }
    if (mounted) context.pop();
  }

  Future<void> _excluir() async {
    final dao = ref.read(bancoProvider).contasDao;
    final c = _original!;
    if (await dao.temLancamentos(c.id)) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Não dá para excluir'),
          content: const Text(
            'Esta conta tem lançamentos. Para tirá-la de uso, desative a opção '
            '"Conta ativa" e salve: ela fica arquivada, com o histórico intacto.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(80, 44)),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: Text('"${c.nome}" será removida.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(80, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await dao.excluir(c.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fechar',
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar conta' : 'Nova conta'),
        actions: [
          if (_edicao)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _excluir,
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _chave,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: [
                          TextFormField(
                            controller: _nome,
                            autofocus: !_edicao,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nome da conta',
                              hintText: 'Ex.: Nubank, Carteira',
                              prefixIcon: Icon(Icons.label_outline_rounded),
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Dê um nome à conta'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          SegmentedButton<TipoConta>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(value: TipoConta.corrente, label: Text('Corrente')),
                              ButtonSegment(value: TipoConta.poupanca, label: Text('Poupança')),
                              ButtonSegment(value: TipoConta.carteira, label: Text('Carteira')),
                            ],
                            selected: {_tipo},
                            onSelectionChanged: (s) => setState(() => _tipo = s.first),
                          ),
                          const SizedBox(height: 24),
                          CampoValor(controller: _saldo, rotulo: 'Saldo inicial'),
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              'Quanto você tem nesta conta hoje. É dinheiro que já existe: '
                              'não conta como ganho nem como salário.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _negativo,
                            onChanged: (v) => setState(() => _negativo = v ?? false),
                            title: const Text('Saldo inicial negativo'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.event_rounded),
                            title: const Text('Data do saldo inicial'),
                            subtitle: Text(FormatoData.dia(_dataSaldo)),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _dataSaldo,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setState(() => _dataSaldo = soData(d));
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _creditoSeguro,
                            onChanged: (v) => setState(() => _creditoSeguro = v),
                            title: const Text('Considerar no crédito seguro'),
                            subtitle: const Text(
                              'O saldo desta conta entra no cálculo de quanto '
                              'dá para gastar no crédito.',
                            ),
                          ),
                          if (_edicao)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _ativa,
                              onChanged: (v) => setState(() => _ativa = v),
                              title: const Text('Conta ativa'),
                              subtitle: const Text('Desative para arquivar sem apagar o histórico.'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvar,
                        child: Text(_edicao ? 'Salvar alterações' : 'Criar conta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
