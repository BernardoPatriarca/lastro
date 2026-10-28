import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/enums.dart';
import 'filtro_lancamentos.dart';

/// Folha de filtros: tipo, categoria, forma, conta e cartão.
Future<void> abrirFiltros(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _FiltrosSheet(),
  );
}

class _FiltrosSheet extends ConsumerStatefulWidget {
  const _FiltrosSheet();

  @override
  ConsumerState<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends ConsumerState<_FiltrosSheet> {
  late FiltroLancamentos _f = ref.read(filtroLancamentosProvider);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final contas = ref.watch(contasProvider).ou;
    final cartoes = ref.watch(cartoesProvider).ou;
    final categorias = [
      for (final c in ref.watch(categoriasProvider).ou) if (c.ativa) c,
    ];

    Widget secao(String titulo, Widget filho) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: tema.textTheme.labelLarge
                      ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              filho,
            ],
          ),
        );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  children: [
                    Text('Filtros',
                        style: tema.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    secao(
                      'Tipo',
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final t in TipoLancamento.values)
                          FilterChip(
                            label: Text(t.rotulo),
                            selected: _f.tipos.contains(t),
                            onSelected: (s) => setState(() {
                              final novo = {..._f.tipos};
                              s ? novo.add(t) : novo.remove(t);
                              _f = _f.copiar(tipos: novo);
                            }),
                          ),
                      ]),
                    ),
                    secao(
                      'Forma de pagamento',
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final f in FormaPagamento.values)
                          ChoiceChip(
                            label: Text(f.rotulo),
                            selected: _f.forma == f,
                            showCheckmark: false,
                            onSelected: (s) => setState(
                                () => _f = _f.copiar(forma: () => s ? f : null)),
                          ),
                      ]),
                    ),
                    if (contas.isNotEmpty)
                      secao(
                        'Conta',
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final c in contas)
                            ChoiceChip(
                              label: Text(c.nome),
                              selected: _f.contaId == c.id,
                              showCheckmark: false,
                              onSelected: (s) => setState(() =>
                                  _f = _f.copiar(contaId: () => s ? c.id : null)),
                            ),
                        ]),
                      ),
                    if (cartoes.isNotEmpty)
                      secao(
                        'Cartão',
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final c in cartoes)
                            ChoiceChip(
                              label: Text(c.nome),
                              selected: _f.cartaoId == c.id,
                              showCheckmark: false,
                              onSelected: (s) => setState(() =>
                                  _f = _f.copiar(cartaoId: () => s ? c.id : null)),
                            ),
                        ]),
                      ),
                    secao(
                      'Categoria',
                      DropdownButtonFormField<int>(
                        initialValue: categorias.any((c) => c.id == _f.categoriaId)
                            ? _f.categoriaId
                            : null,
                        isExpanded: true,
                        hint: const Text('Todas'),
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
                        onChanged: (v) =>
                            setState(() => _f = _f.copiar(categoriaId: () => v)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52)),
                        onPressed: () {
                          ref.read(filtroLancamentosProvider.notifier).limpar();
                          Navigator.pop(context);
                        },
                        child: const Text('Limpar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          ref.read(filtroLancamentosProvider.notifier).definir(_f);
                          Navigator.pop(context);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
