import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/banco.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/enums.dart';

/// Cadastro e edição de investimento (nome e tipo).
class InvestimentoFormPage extends ConsumerStatefulWidget {
  const InvestimentoFormPage({super.key, this.id});
  final int? id;

  @override
  ConsumerState<InvestimentoFormPage> createState() => _State();
}

class _State extends ConsumerState<InvestimentoFormPage> {
  final _chave = GlobalKey<FormState>();
  final _nome = TextEditingController();
  Investimento? _original;
  bool _carregando = false;
  TipoInvestimento _tipo = TipoInvestimento.reserva;
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
    final i = await ref.read(bancoProvider).investimentosDao.investimento(widget.id!);
    if (!mounted) return;
    if (i == null) {
      context.pop();
      return;
    }
    setState(() {
      _original = i;
      _carregando = false;
      _nome.text = i.nome;
      _tipo = i.tipo;
      _ativo = i.ativo;
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final servico = ref.read(servicoInvestimentoProvider);
    final o = _original;
    if (o == null) {
      await servico.criar(nome: _nome.text, tipo: _tipo);
    } else {
      await servico.atualizar(o.copyWith(nome: _nome.text.trim(), tipo: _tipo, ativo: _ativo));
    }
    if (mounted) context.pop();
  }

  Future<void> _excluir() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir investimento?'),
        content: const Text(
          'O histórico de movimentos some. Os aportes e resgates já lançados nas '
          'contas continuam nos lançamentos.',
        ),
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
    await ref.read(servicoInvestimentoProvider).excluirInvestimento(_original!.id);
    if (mounted) context.go('/investimentos');
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
        title: Text(_edicao ? 'Editar investimento' : 'Novo investimento'),
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
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              hintText: 'Ex.: Reserva de emergência, CDB Banco X',
                              prefixIcon: Icon(Icons.savings_outlined),
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Dê um nome ao investimento' : null,
                          ),
                          const SizedBox(height: 20),
                          Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final t in TipoInvestimento.values)
                                ChoiceChip(
                                  label: Text(t.rotulo),
                                  selected: _tipo == t,
                                  showCheckmark: false,
                                  onSelected: (_) => setState(() => _tipo = t),
                                ),
                            ],
                          ),
                          if (_edicao)
                            SwitchListTile(
                              contentPadding: const EdgeInsets.only(top: 12),
                              value: _ativo,
                              onChanged: (v) => setState(() => _ativo = v),
                              title: const Text('Ativo'),
                              subtitle: const Text('Inativo some do patrimônio e da lista.'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvar,
                        child: Text(_edicao ? 'Salvar alterações' : 'Criar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
