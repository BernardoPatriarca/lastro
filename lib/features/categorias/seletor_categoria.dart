import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icones.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/enums.dart';

/// Categorias ativas de [tipo] ordenadas por uso (mais usadas primeiro).
List<Categoria> categoriasOrdenadasPorUso(
  List<Categoria> todas,
  Map<int, int> uso,
  TipoCategoria tipo,
) {
  final lista = [for (final c in todas) if (c.ativa && c.tipo == tipo) c];
  lista.sort((a, b) {
    final porUso = (uso[b.id] ?? 0).compareTo(uso[a.id] ?? 0);
    if (porUso != 0) return porUso;
    return a.ordem.compareTo(b.ordem);
  });
  return lista;
}

/// Cor da categoria como [Color].
Color corDa(Categoria? c, Color padrao) => c == null ? padrao : Color(c.cor);

/// Círculo colorido com o ícone da categoria.
class IconeCategoria extends StatelessWidget {
  const IconeCategoria({super.key, this.categoria, this.tamanho = 44, this.icone});
  final Categoria? categoria;
  final double tamanho;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final cor = corDa(categoria, Theme.of(context).colorScheme.outline);
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(tamanho * 0.34),
      ),
      child: Icon(
        icone ?? iconeDe(categoria?.icone),
        size: tamanho * 0.5,
        color: cor,
      ),
    );
  }
}

/// Chips com as categorias mais usadas + "Mais" para ver todas.
class SeletorCategoria extends ConsumerWidget {
  const SeletorCategoria({
    super.key,
    required this.tipo,
    required this.selecionada,
    required this.onSelecionar,
    this.limite = 7,
  });

  final TipoCategoria tipo;
  final int? selecionada;
  final ValueChanged<int?> onSelecionar;
  final int limite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todas = ref.watch(categoriasProvider).ou;
    final uso = ref.watch(usoCategoriasProvider);
    final ordenadas = categoriasOrdenadasPorUso(todas, uso, tipo);
    final visiveis = ordenadas.take(limite).toList();
    // A escolhida sempre aparece, mesmo fora das mais usadas.
    if (selecionada != null && !visiveis.any((c) => c.id == selecionada)) {
      final escolhida = ordenadas.where((c) => c.id == selecionada);
      if (escolhida.isNotEmpty) visiveis.insert(0, escolhida.first);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in visiveis)
          ChoiceChip(
            avatar: Icon(iconeDe(c.icone), size: 18, color: Color(c.cor)),
            label: Text(c.nome),
            selected: c.id == selecionada,
            showCheckmark: false,
            onSelected: (s) => onSelecionar(s ? c.id : null),
          ),
        if (ordenadas.length > visiveis.length)
          ActionChip(
            avatar: const Icon(Icons.more_horiz_rounded, size: 18),
            label: const Text('Mais'),
            onPressed: () async {
              final id = await escolherCategoria(context, ref, tipo);
              if (id != null) onSelecionar(id);
            },
          ),
      ],
    );
  }
}

/// Folha com todas as categorias (subcategorias recuadas). Devolve o id.
Future<int?> escolherCategoria(
  BuildContext context,
  WidgetRef ref,
  TipoCategoria tipo,
) {
  final todas = [
    for (final c in ref.read(categoriasProvider).ou)
      if (c.ativa && c.tipo == tipo) c,
  ];
  final pais = todas.where((c) => c.categoriaPaiId == null).toList();
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (_, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final pai in pais) ...[
            _LinhaCategoria(categoria: pai, nivel: 0, ctx: ctx),
            for (final f in todas.where((c) => c.categoriaPaiId == pai.id))
              _LinhaCategoria(categoria: f, nivel: 1, ctx: ctx),
          ],
        ],
      ),
    ),
  );
}

class _LinhaCategoria extends StatelessWidget {
  const _LinhaCategoria({
    required this.categoria,
    required this.nivel,
    required this.ctx,
  });
  final Categoria categoria;
  final int nivel;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20.0 + nivel * 28, right: 20),
      leading: IconeCategoria(categoria: categoria, tamanho: nivel == 0 ? 40 : 34),
      title: Text(
        categoria.nome,
        style: TextStyle(fontWeight: nivel == 0 ? FontWeight.w600 : FontWeight.w400),
      ),
      onTap: () => Navigator.of(ctx).pop(categoria.id),
    );
  }
}
