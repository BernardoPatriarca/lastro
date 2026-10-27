import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Tela de login — por enquanto só a identidade visual.
/// A senha (hash + salt), a biometria e o bloqueio automático vêm na Etapa 2.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final logo = escuro
        ? 'assets/branding/lastro-logo-vertical-escuro.svg'
        : 'assets/branding/lastro-logo-vertical-claro.svg';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              SvgPicture.asset(
                logo,
                width: 200,
                semanticsLabel: 'Lastro',
              ),
              const SizedBox(height: 16),
              Text(
                'Seu dinheiro, com lastro.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(flex: 4),
              FilledButton(
                onPressed: () => context.go(Rotas.inicio),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 12),
              Text(
                'Proteção por senha e biometria chega na Etapa 2.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
