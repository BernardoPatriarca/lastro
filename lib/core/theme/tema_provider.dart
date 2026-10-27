import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modo de tema do app. Padrão: escuro (claro e automático ficam disponíveis).
///
/// Na Etapa 1 isto passa a ser persistido na tabela `configuracoes`.
class TemaModoNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void definir(ThemeMode modo) => state = modo;
}

final temaModoProvider =
    NotifierProvider<TemaModoNotifier, ThemeMode>(TemaModoNotifier.new);
