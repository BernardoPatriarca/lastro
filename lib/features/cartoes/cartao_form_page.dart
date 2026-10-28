import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icones.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';

/// Cadastro e edição de cartão.
class CartaoFormPage extends ConsumerStatefulWidget {
  const CartaoFormPage({super.key, this.id});
  final int? id;

  @override
  ConsumerState<CartaoFormPage> createState() => _CartaoFormPageState();
}

class _CartaoFormPageState extends ConsumerState<CartaoFormPage> {
  final _chave = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _limite = ControladorValor();

  Cartao? _original;
  bool _carregando = false;
  int _fechamento = 10;
  int _vencimento = 17;
  int? _contaId;
  int _cor = coresDisponiveis.first;
  bool _ativo = true;

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
    final c = await ref.read(bancoProvider).cartoesDao.obter(widget.id!);
    if (!mounted) return;
    if (c == null) {
      context.pop();
      return;
    }
    setState(() {
      _original = c;
      _carregando = false;
      _nome.text = c.nome;
      _limite.centavos = c.limite;
      _fechamento = c.diaFechamento;
      _vencimento = c.diaVencimento;
      _contaId = c.contaPagamentoId;
      _cor = c.cor;
      _ativo = c.ativo;
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    _limite.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final dao = ref.read(bancoProvider).cartoesDao;
    final o = _original;
    if (o == null) {
      await dao.inserir(CartoesCompanion.insert(
        nome: _nome.text.trim(),
        diaFechamento: _fechamento,
        diaVencimento: _vencimento,
        limite: Value(_limite.centavos),
        contaPagamentoId: Value(_contaId),
        cor: Value(_cor),
      ));
    } else {
      await dao.atualizar(o.copyWith(
        nome: _nome.text.trim(),
        diaFechamento: _fechamento,
        diaVencimento: _vencimento,
        limite: _limite.centavos,
        contaPagamentoId: Value(_contaId),
        cor: _cor,
        ativo: _ativo,
      ));
    }
    if (mounted) context.pop();
  }

  Future<void> _excluir() async {
    final c = _original!;
    final temCompras = ref
        .read(lancamentosProvider)
        .ou
        .any((l) => l.cartaoId == c.id);
    if (temCompras) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Não dá para excluir'),
          content: const Text(
            'Este cartão tem compras. Desative a opção "Cartão ativo" para '
            'arquivá-lo sem perder o histórico.',
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cartão?'),
        content: Text('"${c.nome}" será removido.'),
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
    final db = ref.read(bancoProvider);
    // Faturas vazias do cartão vão junto.
    for (final f in await db.cartoesDao.todasFaturas()) {
      if (f.cartaoId == c.id) {
        await (db.delete(db.faturas)..where((t) => t.id.equals(f.id))).go();
      }
    }
    await db.cartoesDao.excluir(c.id);
    if (mounted) context.go('/cartoes');
  }

  @override
  Widget build(BuildContext context) {
    final contas = ref.watch(contasAtivasProvider);
    final contaValida = contas.any((c) => c.id == _contaId) ? _contaId : null;
    final dias = List.generate(31, (i) => i + 1);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fechar',
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar cartão' : 'Novo cartão'),
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
                              labelText: 'Nome do cartão',
                              hintText: 'Ex.: Nubank Visa',
                              prefixIcon: Icon(Icons.credit_card_rounded),
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Dê um nome ao cartão'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CampoValor(controller: _limite, rotulo: 'Limite'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  initialValue: _fechamento,
                                  decoration: const InputDecoration(labelText: 'Fechamento'),
                                  items: [for (final d in dias) DropdownMenuItem(value: d, child: Text('Dia $d'))],
                                  onChanged: (v) => setState(() => _fechamento = v!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  initialValue: _vencimento,
                                  decoration: const InputDecoration(labelText: 'Vencimento'),
                                  items: [for (final d in dias) DropdownMenuItem(value: d, child: Text('Dia $d'))],
                                  onChanged: (v) => setState(() => _vencimento = v!),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              'Compras a partir do dia do fechamento entram na fatura seguinte.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            key: ValueKey('${contas.length}-$contaValida'),
                            initialValue: contaValida,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Conta que paga a fatura',
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(value: null, child: Text('Escolher na hora de pagar')),
                              for (final c in contas) DropdownMenuItem<int?>(value: c.id, child: Text(c.nome)),
                            ],
                            onChanged: (v) => setState(() => _contaId = v),
                          ),
                          const SizedBox(height: 20),
                          Text('Cor', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final c in coresDisponiveis)
                                GestureDetector(
                                  onTap: () => setState(() => _cor = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Color(c),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cor == c
                                            ? Theme.of(context).colorScheme.onSurface
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: _cor == c
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                          if (_edicao) ...[
                            const SizedBox(height: 8),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _ativo,
                              onChanged: (v) => setState(() => _ativo = v),
                              title: const Text('Cartão ativo'),
                              subtitle: const Text('Desative para arquivar sem apagar o histórico.'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvar,
                        child: Text(_edicao ? 'Salvar alterações' : 'Criar cartão'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
