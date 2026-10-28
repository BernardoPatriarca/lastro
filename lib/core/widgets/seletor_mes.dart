import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/competencia.dart';
import '../formatadores/data.dart';

/// Mês em foco (compartilhado entre Início e Lançamentos).
class MesSelecionado extends Notifier<Competencia> {
  @override
  Competencia build() => Competencia.deData(DateTime.now());

  void definir(Competencia c) => state = c;
  void anterior() => state = state.somarMeses(-1);
  void proximo() => state = state.somarMeses(1);
  void hoje() => state = Competencia.deData(DateTime.now());
}

final mesSelecionadoProvider =
    NotifierProvider<MesSelecionado, Competencia>(MesSelecionado.new);

/// `‹  Março de 2026  ›` — toque no nome para voltar ao mês atual.
class SeletorMes extends ConsumerWidget {
  const SeletorMes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mes = ref.watch(mesSelecionadoProvider);
    final ctl = ref.read(mesSelecionadoProvider.notifier);
    final tema = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Mês anterior',
          onPressed: ctl.anterior,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: ctl.hoje,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  FormatoData.mesAno(mes.primeiroDia),
                  key: ValueKey(mes),
                  style: tema.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Próximo mês',
          onPressed: ctl.proximo,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
