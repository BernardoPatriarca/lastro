import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/banco.dart';
import '../../data/providers.dart';
import '../../domain/enums.dart';
import 'seletor_categoria.dart';

/// CRUD de categorias e subcategorias (abas Gastos e Ganhos). Arraste pela
/// alça para reordenar as categorias principais.
class CategoriasPage extends ConsumerWidget {
  const CategoriasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          actions: [
            IconButton(
              tooltip: 'Regras de categorização',
              icon: const Icon(Icons.auto_fix_high_rounded),
              onPressed: () => context.push(Rotas.regras),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Gastos'), Tab(text: 'Ganhos')],
          ),
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton.extended(
            onPressed: () {
              final aba = DefaultTabController.of(ctx).index;
              context.push('${Rotas.novaCategoria}?tipo=${aba == 0 ? 'gasto' : 'ganho'}');
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nova categoria'),
          ),
        ),
        body: const TabBarView(
          children: [
            _ListaCategorias(tipo: TipoCategoria.gasto),
            _ListaCategorias(tipo: TipoCategoria.ganho),
          ],
        ),
      ),
    );
  }
}

class _ListaCategorias extends ConsumerWidget {
  const _ListaCategorias({required this.tipo});
  final TipoCategoria tipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todas = [
      for (final c in ref.watch(categoriasProvider).ou)
        if (c.tipo == tipo) c,
    ];
    final pais = todas.where((c) => c.categoriaPaiId == null).toList()
      ..sort((a, b) {
        final o = a.ordem.compareTo(b.ordem);
        return o != 0 ? o : a.nome.compareTo(b.nome);
      });
    List<Categoria> filhasDe(int id) => [
          for (final c in todas)
            if (c.categoriaPaiId == id) c,
        ]..sort((a, b) {
            final o = a.ordem.compareTo(b.ordem);
            return o != 0 ? o : a.nome.compareTo(b.nome);
          });

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      buildDefaultDragHandles: false,
      itemCount: pais.length,
      onReorderItem: (de, para) async {
        final nova = [...pais];
        nova.insert(para, nova.removeAt(de));
        final dao = ref.read(bancoProvider).categoriasDao;
        for (var i = 0; i < nova.length; i++) {
          if (nova[i].ordem != i) await dao.atualizar(nova[i].copyWith(ordem: i));
        }
      },
      itemBuilder: (context, i) {
        final pai = pais[i];
        final filhas = filhasDe(pai.id);
        return Padding(
          key: ValueKey(pai.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: Column(
              children: [
                _Linha(
                  categoria: pai,
                  alca: ReorderableDragStartListener(
                    index: i,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.drag_indicator_rounded),
                    ),
                  ),
                ),
                for (final f in filhas) _Linha(categoria: f, recuo: true),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.categoria, this.recuo = false, this.alca});
  final Categoria categoria;
  final bool recuo;
  final Widget? alca;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Opacity(
      opacity: categoria.ativa ? 1 : 0.5,
      child: ListTile(
        contentPadding: EdgeInsets.only(left: recuo ? 40 : 16, right: 8),
        leading: IconeCategoria(categoria: categoria, tamanho: recuo ? 34 : 40),
        title: Text(categoria.nome,
            style: TextStyle(fontWeight: recuo ? FontWeight.w400 : FontWeight.w600)),
        subtitle: categoria.ativa ? null : const Text('arquivada'),
        trailing: alca ??
            Icon(Icons.chevron_right_rounded, color: tema.colorScheme.onSurfaceVariant),
        onTap: () => context.push(Rotas.editarCategoria(categoria.id)),
      ),
    );
  }
}
