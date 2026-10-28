import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';

/// Cadastro e edição de meta: nome, valor-alvo, prazo e investimento vinculado.
class MetaFormPage extends ConsumerStatefulWidget {
  const MetaFormPage({super.key, this.id});
  final int? id;

  @override
  ConsumerState<MetaFormPage> createState() => _MetaFormState();
}

class _MetaFormState extends ConsumerState<MetaFormPage> {
  final _chave = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _alvo = ControladorValor();
  Meta? _original;
  bool _carregando = false;
  DateTime _prazo = soData(DateTime.now().add(const Duration(days: 365)));
  int? _investimentoId;
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
    final metas = await ref.read(bancoProvider).select(ref.read(bancoProvider).metas).get();
    final m = metas.where((x) => x.id == widget.id).firstOrNull;
    if (!mounted) return;
    if (m == null) {
      context.pop();
      return;
    }
    setState(() {
      _original = m;
      _carregando = false;
      _nome.text = m.nome;
      _alvo.centavos = m.valorAlvo;
      _prazo = m.prazo;
      _investimentoId = m.investimentoId;
      _ativa = m.ativa;
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    _alvo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final servico = ref.read(servicoInvestimentoProvider);
    final o = _original;
    if (o == null) {
      await servico.criarMeta(
        nome: _nome.text,
        valorAlvo: _alvo.centavos,
        prazo: _prazo,
        investimentoId: _investimentoId,
      );
    } else {
      await servico.atualizarMeta(o.copyWith(
        nome: _nome.text.trim(),
        valorAlvo: _alvo.centavos,
        prazo: _prazo,
        investimentoId: Value(_investimentoId),
        ativa: _ativa,
      ));
    }
    if (mounted) context.pop();
  }

  Future<void> _excluir() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir meta?'),
        content: Text('"${_original!.nome}" será removida (os investimentos não mudam).'),
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
    await ref.read(servicoInvestimentoProvider).excluirMeta(_original!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final investimentos = [for (final i in ref.watch(investimentosProvider).ou) if (i.ativo) i];
    final valido = investimentos.any((i) => i.id == _investimentoId) ? _investimentoId : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fechar',
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar meta' : 'Nova meta'),
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
                              labelText: 'Nome da meta',
                              hintText: 'Ex.: Viagem, Reserva de 6 meses',
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Dê um nome à meta' : null,
                          ),
                          const SizedBox(height: 16),
                          CampoValor(
                            controller: _alvo,
                            rotulo: 'Valor-alvo',
                            validator: (_) => _alvo.centavos <= 0 ? 'Informe o valor da meta' : null,
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.event_rounded),
                            title: const Text('Prazo'),
                            subtitle: Text(FormatoData.dia(_prazo)),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _prazo,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setState(() => _prazo = soData(d));
                            },
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int?>(
                            key: ValueKey('${investimentos.length}-$valido'),
                            initialValue: valido,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Investimento vinculado',
                              prefixIcon: Icon(Icons.savings_outlined),
                              helperText: 'Sem vínculo, a meta usa o patrimônio total.',
                            ),
                            items: [
                              const DropdownMenuItem<int?>(value: null, child: Text('Todo o patrimônio')),
                              for (final i in investimentos)
                                DropdownMenuItem<int?>(value: i.id, child: Text(i.nome)),
                            ],
                            onChanged: (v) => setState(() => _investimentoId = v),
                          ),
                          if (_edicao)
                            SwitchListTile(
                              contentPadding: const EdgeInsets.only(top: 12),
                              value: _ativa,
                              onChanged: (v) => setState(() => _ativa = v),
                              title: const Text('Meta ativa'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvar,
                        child: Text(_edicao ? 'Salvar alterações' : 'Criar meta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
