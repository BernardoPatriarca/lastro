import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cartoes/cartoes_page.dart';
import '../../features/inicio/inicio_page.dart';
import '../../features/investimentos/investimentos_page.dart';
import '../../features/lancamentos/lancamentos_page.dart';
import '../../features/login/login_page.dart';
import '../../features/mais/mais_page.dart';
import '../../features/shell/shell_page.dart';

/// Caminhos das rotas do app.
abstract final class Rotas {
  static const login = '/login';
  static const inicio = '/inicio';
  static const lancamentos = '/lancamentos';
  static const cartoes = '/cartoes';
  static const investimentos = '/investimentos';
  static const mais = '/mais';
}

/// Monta o roteador. Função separada para os testes criarem um por teste.
GoRouter criarRouter({String inicial = Rotas.login}) {
  return GoRouter(
    initialLocation: inicial,
    routes: [
      // Provisório: na Etapa 2 o login passa a proteger o acesso ao app.
      GoRoute(path: Rotas.login, builder: (_, _) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            ShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.inicio, builder: (_, _) => const InicioPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Rotas.lancamentos,
              builder: (_, _) => const LancamentosPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.cartoes, builder: (_, _) => const CartoesPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Rotas.investimentos,
              builder: (_, _) => const InvestimentosPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.mais, builder: (_, _) => const MaisPage()),
          ]),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = criarRouter();
  ref.onDispose(router.dispose);
  return router;
});
