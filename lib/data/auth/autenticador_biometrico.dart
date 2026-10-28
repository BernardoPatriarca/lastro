import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometria do aparelho (digital/rosto). Isolada para facilitar testes.
abstract interface class AutenticadorBiometrico {
  Future<bool> disponivel();
  Future<bool> autenticar(String motivo);
}

class AutenticadorBiometricoPlataforma implements AutenticadorBiometrico {
  final _auth = LocalAuthentication();

  @override
  Future<bool> disponivel() async {
    try {
      final suporta = await _auth.isDeviceSupported();
      final biometrias = await _auth.getAvailableBiometrics();
      return suporta && biometrias.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> autenticar(String motivo) async {
    try {
      return await _auth.authenticate(
        localizedReason: motivo,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    } on LocalAuthException {
      return false;
    }
  }
}

class AutenticadorBiometricoFalso implements AutenticadorBiometrico {
  AutenticadorBiometricoFalso({this.existe = false, this.aceita = true});
  final bool existe;
  final bool aceita;

  @override
  Future<bool> disponivel() async => existe;
  @override
  Future<bool> autenticar(String motivo) async => aceita;
}
