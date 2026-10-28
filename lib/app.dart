import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/tema.dart';
import 'data/providers.dart';
import 'features/login/guarda_sessao.dart';

class LastroApp extends ConsumerWidget {
  const LastroApp({super.key});

  static ThemeMode _modo(String tema) => switch (tema) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(ajustesProvider.select((a) => _modo(a.tema)));
    return GuardaSessao(
      child: MaterialApp.router(
        title: 'Lastro',
        debugShowCheckedModeBanner: false,
        theme: TemaLastro.claro,
        darkTheme: TemaLastro.escuro,
        themeMode: modo,
        routerConfig: ref.watch(routerProvider),
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
