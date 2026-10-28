import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth/armazenamento_seguro.dart';
import '../../data/auth/autenticador_biometrico.dart';
import '../../data/auth/servico_senha.dart';
import '../../data/providers.dart';

enum EstadoAuth { carregando, semSenha, bloqueado, liberado }

final armazenamentoSeguroProvider = Provider<ArmazenamentoSeguro>(
  (ref) => ArmazenamentoSeguroPlataforma(),
);

final servicoSenhaProvider = Provider<ServicoSenha>(
  (ref) => ServicoSenha(ref.watch(armazenamentoSeguroProvider)),
);

final autenticadorBiometricoProvider = Provider<AutenticadorBiometrico>(
  (ref) => AutenticadorBiometricoPlataforma(),
);

/// Dono do estado de sessão: define senha, entra, bloqueia.
class AuthController extends Notifier<EstadoAuth> {
  DateTime? _foiParaSegundoPlano;

  @override
  EstadoAuth build() {
    _iniciar();
    return EstadoAuth.carregando;
  }

  ServicoSenha get _senha => ref.read(servicoSenhaProvider);

  Future<void> _iniciar() async {
    final tem = await _senha.temSenha();
    state = tem ? EstadoAuth.bloqueado : EstadoAuth.semSenha;
  }

  Future<void> criarSenha(String senha, {required bool biometria}) async {
    await _senha.definirSenha(senha);
    await ref.read(definirAjusteProvider)('biometria', '$biometria');
    state = EstadoAuth.liberado;
  }

  Future<ResultadoLogin> entrarComSenha(String senha) async {
    final r = await _senha.verificar(senha);
    if (r is LoginOk) state = EstadoAuth.liberado;
    return r;
  }

  /// Retorna `true` se a biometria liberou o app.
  Future<bool> entrarComBiometria() async {
    if (!ref.read(ajustesProvider).biometria) return false;
    final bio = ref.read(autenticadorBiometricoProvider);
    if (!await bio.disponivel()) return false;
    final ok = await bio.autenticar('Desbloqueie o Lastro');
    if (ok) state = EstadoAuth.liberado;
    return ok;
  }

  void bloquear() {
    if (state == EstadoAuth.liberado) state = EstadoAuth.bloqueado;
  }

  /// O app saiu da tela (segundo plano).
  void foiParaSegundoPlano() => _foiParaSegundoPlano = DateTime.now();

  /// O app voltou: bloqueia se ficou fora por mais que o tempo configurado.
  void voltouDoSegundoPlano() {
    final saiu = _foiParaSegundoPlano;
    _foiParaSegundoPlano = null;
    if (saiu == null || state != EstadoAuth.liberado) return;
    final limite = Duration(minutes: ref.read(ajustesProvider).bloqueioMinutos);
    if (DateTime.now().difference(saiu) >= limite) bloquear();
  }
}

final authProvider =
    NotifierProvider<AuthController, EstadoAuth>(AuthController.new);
