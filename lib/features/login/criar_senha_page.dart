import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'auth_controller.dart';

/// Primeira abertura: o dono define a senha e escolhe se ativa a biometria.
class CriarSenhaPage extends ConsumerStatefulWidget {
  const CriarSenhaPage({super.key});

  @override
  ConsumerState<CriarSenhaPage> createState() => _CriarSenhaPageState();
}

class _CriarSenhaPageState extends ConsumerState<CriarSenhaPage> {
  static const tamanhoMinimo = 6;

  final _chave = GlobalKey<FormState>();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();
  bool _ocultar = true;
  bool _biometria = false;
  bool _biometriaDisponivel = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    ref.read(autenticadorBiometricoProvider).disponivel().then((v) {
      if (mounted) setState(() => _biometriaDisponivel = v);
    });
  }

  @override
  void dispose() {
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate() || _salvando) return;
    setState(() => _salvando = true);
    if (_biometria) {
      final ok = await ref
          .read(autenticadorBiometricoProvider)
          .autenticar('Confirme sua biometria para ativá-la');
      if (!ok) _biometria = false;
    }
    await ref
        .read(authProvider.notifier)
        .criarSenha(_senha.text, biometria: _biometria);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _chave,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        escuro
                            ? 'assets/branding/lastro-logo-vertical-escuro.svg'
                            : 'assets/branding/lastro-logo-vertical-claro.svg',
                        width: 150,
                        semanticsLabel: 'Lastro',
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Crie sua senha',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ela protege seus dados neste celular. '
                      'Não há como recuperá-la: guarde-a bem.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _senha,
                      obscureText: _ocultar,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
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
                      validator: (v) => (v ?? '').length < tamanhoMinimo
                          ? 'Use pelo menos $tamanhoMinimo caracteres'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirma,
                      obscureText: _ocultar,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _salvar(),
                      decoration: const InputDecoration(
                        labelText: 'Confirme a senha',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: (v) =>
                          v != _senha.text ? 'As senhas não conferem' : null,
                    ),
                    if (_biometriaDisponivel) ...[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _biometria,
                        onChanged: (v) => setState(() => _biometria = v),
                        title: const Text('Entrar com biometria'),
                        subtitle: const Text('Digital ou rosto, quando disponível'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _salvando ? null : _salvar,
                      child: _salvando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Começar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
