import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/categorizacao.dart';
import '../../domain/enums.dart';
import '../../core/widgets/estado_vazio.dart';
import 'seletor_categoria.dart';

/// Regras de categorização: "descrições com X → Categoria Y". Usadas na
/// importação de extratos. Há um campo para testar uma descrição.
class RegrasPage extends ConsumerStatefulWidget {
  const RegrasPage({super.key});

  @override
  ConsumerState<RegrasPage> createState() => _RegrasPageState();
}

class _RegrasPageState extends ConsumerState<RegrasPage> {
  final _teste = TextEditingController();

  @override
  void dispose() {
    _teste.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regras = ref.watch(regrasProvider).ou;
    final categorias = ref.watch(categoriasPorIdProvider);
    final tema = Theme.of(context);

    final sugerida = _teste.text.trim().isEmpty
        ? null
        : categoriaSugerida(_teste.text, [
            for (final r in regras)
              RegraSimples(
                id: r.id,
                padrao: r.padrao,
                categoriaId: r.categoriaId,
                prioridade: r.prioridade,
              ),
          ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Regras de categorização')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => editarRegra(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova regra'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          Text(
            'Quando a descrição de um lançamento importado contém o texto da '
            'regra, a categoria é sugerida automaticamente. Não importa acento '
            'nem maiúscula.',
            style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _teste,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Testar uma descrição',
              hintText: 'Ex.: UBER *TRIP 1234',
              prefixIcon: const Icon(Icons.science_outlined),
              helperText: _teste.text.trim().isEmpty
                  ? null
                  : sugerida == null
                      ? 'Nenhuma regra casa com essa descrição.'
                      : 'Seria categorizada como: ${categorias[sugerida]?.nome ?? '—'}',
            ),
          ),
          const SizedBox(height: 16),
          if (regras.isEmpty)
            const SizedBox(
              height: 300,
              child: EstadoVazio(
                icone: Icons.auto_fix_high_rounded,
                titulo: 'Nenhuma regra ainda',
                mensagem: 'Crie regras como "uber → Transporte" para o app '
                    'categorizar sozinho os extratos que você importar.',
              ),
            )
          else
            for (final r in regras)
              Dismissible(
                key: ValueKey(r.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: tema.colorScheme.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.delete_rounded, color: tema.colorScheme.onError),
                ),
                confirmDismiss: (_) async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir regra?'),
                      content: Text('"${r.padrao}" deixa de categorizar automaticamente.'),
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
                  if (ok != true) return false;
                  await ref.read(bancoProvider).categoriasDao.excluirRegra(r.id);
                  return true;
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: IconeCategoria(categoria: categorias[r.categoriaId]),
                      title: Text('"${r.padrao}"'),
                      subtitle: Text(
                        '→ ${categorias[r.categoriaId]?.nome ?? 'categoria removida'}'
                        '${r.prioridade != 0 ? ' · prioridade ${r.prioridade}' : ''}',
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => editarRegra(context, ref, regra: r),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Folha para criar ou editar uma regra. Devolve `true` se salvou.
Future<bool> editarRegra(
  BuildContext context,
  WidgetRef ref, {
  RegraCategorizacao? regra,
  String? padraoInicial,
  int? categoriaInicial,
}) async {
  final resultado = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FormRegra(
      regra: regra,
      padraoInicial: padraoInicial,
      categoriaInicial: categoriaInicial,
    ),
  );
  return resultado == true;
}

class _FormRegra extends ConsumerStatefulWidget {
  const _FormRegra({this.regra, this.padraoInicial, this.categoriaInicial});
  final RegraCategorizacao? regra;
  final String? padraoInicial;
  final int? categoriaInicial;

  @override
  ConsumerState<_FormRegra> createState() => _FormRegraState();
}

class _FormRegraState extends ConsumerState<_FormRegra> {
  late final _padrao = TextEditingController(
    text: widget.regra?.padrao ?? widget.padraoInicial ?? '',
  );
  late int? _categoriaId = widget.regra?.categoriaId ?? widget.categoriaInicial;
  late int _prioridade = widget.regra?.prioridade ?? 0;
  String? _erro;

  @override
  void dispose() {
    _padrao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_padrao.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o texto a procurar');
      return;
    }
    if (_categoriaId == null) {
      setState(() => _erro = 'Escolha a categoria');
      return;
    }
    final dao = ref.read(bancoProvider).categoriasDao;
    final r = widget.regra;
    if (r == null) {
      await dao.inserirRegra(RegrasCategorizacaoCompanion.insert(
        padrao: _padrao.text.trim(),
        categoriaId: _categoriaId!,
        prioridade: Value(_prioridade),
      ));
    } else {
      await dao.atualizarRegra(r.copyWith(
        padrao: _padrao.text.trim(),
        categoriaId: _categoriaId!,
        prioridade: _prioridade,
      ));
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = [
      for (final c in ref.watch(categoriasProvider).ou)
        if (c.ativa) c,
    ];
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.regra == null ? 'Nova regra' : 'Editar regra',
                style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _padrao,
              autofocus: widget.regra == null,
              decoration: const InputDecoration(
                labelText: 'Descrições que contêm',
                hintText: 'Ex.: uber, ifood, padaria',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: categorias.any((c) => c.id == _categoriaId) ? _categoriaId : null,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final c in categorias)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      '${c.categoriaPaiId != null ? '   ' : ''}${c.nome}'
                      '${c.tipo == TipoCategoria.ganho ? ' (ganho)' : ''}',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _categoriaId = v),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text('Prioridade (maior vence quando duas regras casam)'),
                ),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _prioridade--),
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: 36,
                  child: Text('$_prioridade', textAlign: TextAlign.center),
                ),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _prioridade++),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_erro!, style: TextStyle(color: tema.colorScheme.error)),
              ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _salvar, child: const Text('Salvar regra')),
          ],
        ),
      ),
    );
  }
}
