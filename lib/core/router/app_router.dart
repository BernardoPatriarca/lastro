import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cartoes/cartao_detalhe_page.dart';
import '../../features/cartoes/cartao_form_page.dart';
import '../../features/categorias/categoria_form_page.dart';
import '../../features/categorias/categorias_page.dart';
import '../../features/categorias/regras_page.dart';
import '../../features/compromissos/compromisso_form_page.dart';
import '../../features/compromissos/compromissos_page.dart';
import '../../features/compromissos/receita_form_page.dart';
import '../../features/configuracoes/configuracoes_page.dart';
import '../../features/contas/conta_form_page.dart';
import '../../features/contas/contas_page.dart';
import '../../features/importacao/importar_page.dart';
import '../../features/orcamento/orcamento_page.dart';
import '../../features/investimentos/investimento_detalhe_page.dart';
import '../../features/investimentos/investimento_form_page.dart';
import '../../features/investimentos/meta_form_page.dart';
import '../../features/importacao/mapear_csv_page.dart';
import '../../features/importacao/revisao_page.dart';
import '../../features/lancamentos/lancamento_form_page.dart';

import '../../features/cartoes/cartoes_page.dart';
import '../../features/inicio/inicio_page.dart';
import '../../features/investimentos/investimentos_page.dart';
import '../../features/lancamentos/lancamentos_page.dart';
import '../../features/login/auth_controller.dart';
import '../../features/login/criar_senha_page.dart';
import '../../features/login/login_page.dart';
import '../../features/mais/mais_page.dart';
import '../../features/shell/shell_page.dart';

/// Caminhos das rotas do app.
abstract final class Rotas {
  static const carregando = '/carregando';
  static const criarSenha = '/criar-senha';
  static const login = '/login';
  static const inicio = '/inicio';
  static const lancamentos = '/lancamentos';
  static const cartoes = '/cartoes';
  static const investimentos = '/investimentos';
  static const mais = '/mais';

  // Dentro da aba Mais.
  static const contas = '/mais/contas';
  static const compromissos = '/mais/compromissos';
  static const configuracoes = '/mais/configuracoes';
  static const categorias = '/mais/categorias';
  static const regras = '/mais/categorias/regras';
  static const orcamento = '/mais/orcamento';
  static const importar = '/mais/importar';
  static const importarMapear = '/mais/importar/mapear';
  static const importarRevisar = '/mais/importar/revisar';

  // Formulários em tela cheia (por cima da barra inferior).
  static const novoLancamento = '/lancamento/novo';
  static String editarLancamento(int id) => '/lancamento/$id';
  static const novoCartao = '/cartao/novo';
  static String editarCartao(int id) => '/cartao/$id/editar';
  static String cartao(int id) => '/cartoes/$id';
  static const novoCompromisso = '/compromisso/novo';
  static String editarCompromisso(int id) => '/compromisso/$id';
  static const novaReceita = '/receita/nova';
  static String editarReceita(int id) => '/receita/$id';
  static String investimento(int id) => '/investimentos/$id';
  static const novoInvestimento = '/investimento/novo';
  static String editarInvestimento(int id) => '/investimento/$id/editar';
  static const novaMeta = '/meta/nova';
  static String editarMeta(int id) => '/meta/$id';
  static const novaCategoria = '/categoria/nova';
  static String editarCategoria(int id) => '/categoria/$id';
  static const novaConta = '/conta/nova';
  static String editarConta(int id) => '/conta/$id';
}

/// Esconde o aviso (SnackBar) ao abrir uma tela nova: ele ficaria por cima do
/// botão principal dos formulários.
class _EscondeAvisos extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final contexto = navigator?.context;
    if (contexto != null) ScaffoldMessenger.maybeOf(contexto)?.hideCurrentSnackBar();
  }
}

/// Navegador raiz: formulários abrem por cima da barra inferior.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Transição de "folha subindo" para formulários em tela cheia.
Page<void> paginaModal(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animacao, _, filho) => SlideTransition(
        position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(animacao),
        child: FadeTransition(opacity: animacao, child: filho),
      ),
    );

/// Monta o roteador. [estado] diz em que ponto da sessão o app está; o
/// roteador leva sozinho para criar senha, login ou Início.
GoRouter criarRouter({
  required EstadoAuth Function() estado,
  Listenable? atualizarQuando,
  String? inicial,
}) {
  String? redirecionar(BuildContext _, GoRouterState rota) {
    final local = rota.matchedLocation;
    final alvo = switch (estado()) {
      EstadoAuth.carregando => Rotas.carregando,
      EstadoAuth.semSenha => Rotas.criarSenha,
      EstadoAuth.bloqueado => Rotas.login,
      EstadoAuth.liberado => const {
            Rotas.carregando,
            Rotas.criarSenha,
            Rotas.login,
          }.contains(local)
          ? Rotas.inicio
          : local,
    };
    return alvo == local ? null : alvo;
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [_EscondeAvisos()],
    initialLocation: inicial ?? Rotas.carregando,
    refreshListenable: atualizarQuando,
    redirect: redirecionar,
    routes: [
      GoRoute(
        path: Rotas.carregando,
        builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
      ),
      GoRoute(path: Rotas.criarSenha, builder: (_, _) => const CriarSenhaPage()),
      GoRoute(path: Rotas.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: Rotas.novoLancamento,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          LancamentoFormPage(
            tipoInicial: state.uri.queryParameters['tipo'],
            contaInicial: int.tryParse(state.uri.queryParameters['conta'] ?? ''),
          ),
        ),
      ),
      GoRoute(
        path: '/lancamento/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          LancamentoFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: Rotas.novoCartao,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(state, const CartaoFormPage()),
      ),
      GoRoute(
        path: '/cartao/:id/editar',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          CartaoFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: Rotas.novoCompromisso,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(state, const CompromissoFormPage()),
      ),
      GoRoute(
        path: '/compromisso/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          CompromissoFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: Rotas.novaReceita,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(state, const ReceitaFormPage()),
      ),
      GoRoute(
        path: '/receita/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          ReceitaFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: Rotas.novoInvestimento,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(state, const InvestimentoFormPage()),
      ),
      GoRoute(
        path: '/investimento/:id/editar',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          InvestimentoFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: Rotas.novaMeta,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(state, const MetaFormPage()),
      ),
      GoRoute(
        path: '/meta/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          MetaFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: Rotas.novaCategoria,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          CategoriaFormPage(tipoInicial: state.uri.queryParameters['tipo']),
        ),
      ),
      GoRoute(
        path: '/categoria/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          CategoriaFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: Rotas.novaConta,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(state, const ContaFormPage()),
      ),
      GoRoute(
        path: '/conta/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (_, state) => paginaModal(
          state,
          ContaFormPage(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
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
            GoRoute(
              path: Rotas.cartoes,
              builder: (_, _) => const CartoesPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => CartaoDetalhePage(
                    id: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Rotas.investimentos,
              builder: (_, _) => const InvestimentosPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => InvestimentoDetalhePage(
                    id: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Rotas.mais,
              builder: (_, _) => const MaisPage(),
              routes: [
                GoRoute(path: 'contas', builder: (_, _) => const ContasPage()),
                GoRoute(
                  path: 'categorias',
                  builder: (_, _) => const CategoriasPage(),
                  routes: [
                    GoRoute(path: 'regras', builder: (_, _) => const RegrasPage()),
                  ],
                ),
                GoRoute(path: 'orcamento', builder: (_, _) => const OrcamentoPage()),
                GoRoute(
                  path: 'importar',
                  builder: (_, _) => const ImportarPage(),
                  routes: [
                    GoRoute(path: 'mapear', builder: (_, _) => const MapearCsvPage()),
                    GoRoute(path: 'revisar', builder: (_, _) => const RevisaoImportacaoPage()),
                  ],
                ),
                GoRoute(
                  path: 'configuracoes',
                  builder: (_, _) => const ConfiguracoesPage(),
                ),
                GoRoute(
                  path: 'compromissos',
                  builder: (_, _) => const CompromissosPage(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final mudou = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => mudou.value++);
  final router = criarRouter(
    estado: () => ref.read(authProvider),
    atualizarQuando: mudou,
  );
  ref.onDispose(() {
    router.dispose();
    mudou.dispose();
  });
  return router;
});
