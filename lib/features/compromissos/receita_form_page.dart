import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../categorias/seletor_categoria.dart';

/// Cadastro/edição de receita recorrente (gera uma "prevista" por mês).
class ReceitaFormPage extends ConsumerStatefulWidget {
  const ReceitaFormPage({super.key, this.id});
  final int? id;

  @override
  ConsumerState<ReceitaFormPage> createState() => _ReceitaFormPageState();
}

class _ReceitaFormPageState extends ConsumerState<ReceitaFormPage> {
  final _chave = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _valor = ControladorValor();

  ReceitaRecorrente? _original;
  bool _carregando = false;
  DateTime _inicio = soData(DateTime.now());
  int? _contaId;
  int? _categoriaId;
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
    final r = await ref.read(bancoProvider).compromissosDao.receita(widget.id!);
    if (!mounted) return;
    if (r == null) {
      context.pop();
      return;
    }
    setState(() {
      _original = r;
      _carregando = false;
      _descricao.text = r.descricao;
      _valor.centavos = r.valorPrevisto;
      _inicio = r.dataInicio;
      _contaId = r.contaId;
      _categoriaId = r.categoriaId;
      _ativa = r.ativa;
    });
  }

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final contas = ref.read(contasAtivasProvider);
    final contaId = _contaId ?? (contas.isNotEmpty ? contas.first.id : null);
    if (contaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cadastre uma conta antes.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final servico = ref.read(servicoCompromissoProvider);
    final o = _original;
    if (o == null) {
      await servico.criarReceita(
        descricao: _descricao.text,
        valorPrevisto: _valor.centavos,
        contaId: contaId,
        dataInicio: _inicio,
        categoriaId: _categoriaId,
      );
    } else {
      await servico.atualizarReceita(o.copyWith(
        descricao: _descricao.text.trim(),
        valorPrevisto: _valor.centavos,
        contaId: contaId,
        ativa: _ativa,
        diaPrevisto: _inicio.day,
        dataInicio: _inicio,
      ));
    }
    if (mounted) context.pop();
  }

  Future<void> _excluir() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita recorrente?'),
        content: const Text('Os ganhos já lançados continuam na lista.'),
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
    await ref.read(servicoCompromissoProvider).excluirReceita(_original!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final contas = ref.watch(contasAtivasProvider);
    final contaValida = contas.any((c) => c.id == _contaId) ? _contaId : null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fechar',
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar receita' : 'Nova receita recorrente'),
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
                            controller: _descricao,
                            autofocus: !_edicao,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Ex.: Salário',
                              prefixIcon: Icon(Icons.label_outline_rounded),
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Descreva a receita' : null,
                          ),
                          const SizedBox(height: 16),
                          CampoValor(
                            controller: _valor,
                            rotulo: 'Valor previsto',
                            validator: (_) =>
                                _valor.centavos <= 0 ? 'Informe o valor' : null,
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.event_rounded),
                            title: const Text('Começa em'),
                            subtitle: Text(
                              '${FormatoData.dia(_inicio)} · prevista todo dia ${_inicio.day}',
                            ),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _inicio,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setState(() => _inicio = soData(d));
                            },
                          ),
                          const SizedBox(height: 8),
                          Text('Categoria', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          SeletorCategoria(
                            tipo: TipoCategoria.ganho,
                            selecionada: _categoriaId,
                            onSelecionar: (id) => setState(() => _categoriaId = id),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<int>(
                            key: ValueKey('${contas.length}-$contaValida'),
                            initialValue: contaValida,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Conta que recebe',
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                            ),
                            items: [for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome))],
                            onChanged: (v) => setState(() => _contaId = v),
                          ),
                          if (_edicao)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _ativa,
                              onChanged: (v) => setState(() => _ativa = v),
                              title: const Text('Ativa'),
                              subtitle: const Text('Desligue para pausar sem apagar.'),
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
