import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/auth/servico_senha.dart';
import '../../data/providers.dart';
import 'auth_controller.dart';

/// Tela de desbloqueio: biometria (se ativa) ou senha.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _senha = TextEditingController();
  bool _ocultar = true;
  bool _verificando = false;
  String? _erro;
  Duration? _espera;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final falta = await ref.read(servicoSenhaProvider).bloqueioRestante();
      if (falta != null) _iniciarEspera(falta);
      if (falta == null && ref.read(ajustesProvider).biometria) _biometria();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _biometria() async {
    await ref.read(authProvider.notifier).entrarComBiometria();
  }

  void _iniciarEspera(Duration total) {
    _timer?.cancel();
    setState(() => _espera = total);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final falta = _espera! - const Duration(seconds: 1);
      if (falta <= Duration.zero) {
        t.cancel();
        setState(() {
          _espera = null;
          _erro = null;
        });
      } else {
        setState(() => _espera = falta);
      }
    });
  }

  Future<void> _entrar() async {
    if (_verificando || _espera != null || _senha.text.isEmpty) return;
    setState(() {
      _verificando = true;
      _erro = null;
    });
    final r = await ref.read(authProvider.notifier).entrarComSenha(_senha.text);
    if (!mounted) return;
    setState(() => _verificando = false);
    switch (r) {
      case LoginOk():
        break; // o roteador leva ao Início
      case LoginSenhaErrada(:final tentativasRestantes):
        _senha.clear();
        setState(() => _erro = tentativasRestantes == 1
            ? 'Senha incorreta. Última tentativa antes do bloqueio.'
            : 'Senha incorreta. Restam $tentativasRestantes tentativas.');
        HapticFeedback.mediumImpact();
      case LoginBloqueado(:final espera):
        _senha.clear();
        _iniciarEspera(espera);
        HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;
    final bio = ref.watch(ajustesProvider.select((a) => a.biometria));
    final bloqueado = _espera != null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    escuro
                        ? 'assets/branding/lastro-logo-vertical-escuro.svg'
                        : 'assets/branding/lastro-logo-vertical-claro.svg',
                    width: 190,
                    semanticsLabel: 'Lastro',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Seu dinheiro, com lastro.',
                    style: tema.textTheme.bodyLarge?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _senha,
                    enabled: !bloqueado,
                    obscureText: _ocultar,
                    autofocus: !bio,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _entrar(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(_ocultar
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _ocultar = !_ocultar),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: (_erro != null || bloqueado)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              bloqueado
                                  ? 'Muitas tentativas. Tente de novo em '
                                      '${_espera!.inSeconds} s.'
                                  : _erro!,
                              textAlign: TextAlign.center,
                              style: tema.textTheme.bodyMedium?.copyWith(
                                color: tema.colorScheme.error,
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: bloqueado || _verificando ? null : _entrar,
                    child: _verificando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Entrar'),
                  ),
                  if (bio) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: bloqueado ? null : _biometria,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Usar biometria'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
