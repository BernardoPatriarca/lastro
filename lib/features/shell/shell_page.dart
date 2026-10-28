import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Casca com a barra inferior (Início · Lançamentos · Cartões ·
/// Investimentos · Mais) e o botão flutuante "+" de lançamento rápido.
class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _indiceMais = 4;

  @override
  Widget build(BuildContext context) {
    final emMais = navigationShell.currentIndex == _indiceMais;
    return Scaffold(
      body: navigationShell,
      floatingActionButton: emMais
          ? null
          : FloatingActionButton(
              tooltip: 'Lançamento rápido',
              onPressed: () => context.push(Rotas.novoLancamento),
              child: const Icon(Icons.add_rounded, size: 28),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (indice) => navigationShell.goBranch(
          indice,
          // Tocar na aba atual volta para a raiz dela.
          initialLocation: indice == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Lançamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card_rounded),
            label: 'Cartões',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'Investimentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}
