import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icones.dart';
import '../../data/banco.dart';
import '../../data/providers.dart';
import '../../domain/enums.dart';

/// Cadastro e edição de categoria ou subcategoria.
class CategoriaFormPage extends ConsumerStatefulWidget {
  const CategoriaFormPage({super.key, this.id, this.tipoInicial});
  final int? id;

  /// `gasto` ou `ganho` (só na criação).
  final String? tipoInicial;

  @override
  ConsumerState<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends ConsumerState<CategoriaFormPage> {
  final _chave = GlobalKey<FormState>();
  final _nome = TextEditingController();

  Categoria? _original;
  bool _carregando = false;
  TipoCategoria _tipo = TipoCategoria.gasto;
  int? _paiId;
  String _icone = 'category';
  int _cor = coresDisponiveis[1];
  bool _ativa = true;
  bool _temFilhas = false;

  bool get _edicao => widget.id != null;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial == 'ganho' ? TipoCategoria.ganho : TipoCategoria.gasto;
    if (_edicao) {
      _carregando = true;
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final dao = ref.read(bancoProvider).categoriasDao;
    final c = await dao.obter(widget.id!);
    if (!mounted) return;
    if (c == null) {
      context.pop();
      return;
    }
    final filhas = (await dao.todas()).any((x) => x.categoriaPaiId == c.id);
    if (!mounted) return;
    setState(() {
      _original = c;
      _carregando = false;
      _nome.text = c.nome;
      _tipo = c.tipo;
      _paiId = c.categoriaPaiId;
      _icone = c.icone;
      _cor = c.cor;
      _ativa = c.ativa;
      _temFilhas = filhas;
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final dao = ref.read(bancoProvider).categoriasDao;
    final o = _original;
    if (o == null) {
      await dao.inserir(CategoriasCompanion.insert(
        nome: _nome.text.trim(),
        tipo: _tipo,
        icone: Value(_icone),
        cor: Value(_cor),
        categoriaPaiId: Value(_paiId),
        ordem: Value(ref.read(categoriasProvider).ou.length),
      ));
    } else {
      await dao.atualizar(o.copyWith(
        nome: _nome.text.trim(),
        icone: _icone,
        cor: _cor,
        categoriaPaiId: Value(_paiId),
        ativa: _ativa,
      ));
    }
    if (mounted) context.pop();
  }

  Future<void> _excluir() async {
    final dao = ref.read(bancoProvider).categoriasDao;
    final c = _original!;
    if (await dao.emUso(c.id)) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Não dá para excluir'),
          content: const Text(
            'Esta categoria tem lançamentos ou subcategorias. Desative '
            '"Categoria ativa" para arquivá-la sem perder o histórico.',
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
        title: const Text('Excluir categoria?'),
        content: Text('"${c.nome}" e as regras ligadas a ela serão removidas.'),
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
    final todas = ref.watch(categoriasProvider).ou;
    // Só categorias principais do mesmo tipo podem ser "pai" (e nunca ela mesma).
    final possiveisPais = [
      for (final c in todas)
        if (c.tipo == _tipo && c.categoriaPaiId == null && c.id != widget.id) c,
    ];
    final paiValido = possiveisPais.any((c) => c.id == _paiId) ? _paiId : null;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fechar',
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar categoria' : 'Nova categoria'),
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
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Color(_cor).withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(iconeDe(_icone), size: 36, color: Color(_cor)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nome,
                            autofocus: !_edicao,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              prefixIcon: Icon(Icons.label_outline_rounded),
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Dê um nome à categoria' : null,
                          ),
                          const SizedBox(height: 16),
                          IgnorePointer(
                            ignoring: _edicao,
                            child: Opacity(
                              opacity: _edicao ? 0.55 : 1,
                              child: SegmentedButton<TipoCategoria>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment(value: TipoCategoria.gasto, label: Text('Gasto')),
                                  ButtonSegment(value: TipoCategoria.ganho, label: Text('Ganho')),
                                ],
                                selected: {_tipo},
                                onSelectionChanged: (s) => setState(() {
                                  _tipo = s.first;
                                  _paiId = null;
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            key: ValueKey('$_tipo-$paiValido-$_temFilhas'),
                            initialValue: paiValido,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Subcategoria de',
                              helperText: _temFilhas
                                  ? 'Esta categoria tem subcategorias e não pode ser filha.'
                                  : null,
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Nenhuma (categoria principal)'),
                              ),
                              for (final c in possiveisPais)
                                DropdownMenuItem<int?>(value: c.id, child: Text(c.nome)),
                            ],
                            onChanged: _temFilhas ? null : (v) => setState(() => _paiId = v),
                          ),
                          const SizedBox(height: 20),
                          Text('Cor', style: tema.textTheme.labelLarge),
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
                                            ? tema.colorScheme.onSurface
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
                          const SizedBox(height: 20),
                          Text('Ícone', style: tema.textTheme.labelLarge),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final e in iconesCategoria.entries)
                                InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => setState(() => _icone = e.key),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _icone == e.key
                                          ? Color(_cor).withValues(alpha: 0.2)
                                          : tema.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _icone == e.key ? Color(_cor) : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(e.value,
                                        color: _icone == e.key
                                            ? Color(_cor)
                                            : tema.colorScheme.onSurfaceVariant),
                                  ),
                                ),
                            ],
                          ),
                          if (_edicao)
                            SwitchListTile(
                              contentPadding: const EdgeInsets.only(top: 12),
                              value: _ativa,
                              onChanged: (v) => setState(() => _ativa = v),
                              title: const Text('Categoria ativa'),
                              subtitle: const Text('Arquivada some das listas de escolha, mas o histórico fica.'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvar,
                        child: Text(_edicao ? 'Salvar alterações' : 'Criar categoria'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
