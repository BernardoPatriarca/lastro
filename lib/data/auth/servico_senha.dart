import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'armazenamento_seguro.dart';

sealed class ResultadoLogin {
  const ResultadoLogin();
}

class LoginOk extends ResultadoLogin {
  const LoginOk();
}

class LoginSenhaErrada extends ResultadoLogin {
  const LoginSenhaErrada(this.tentativasRestantes);
  final int tentativasRestantes;
}

class LoginBloqueado extends ResultadoLogin {
  const LoginBloqueado(this.espera);
  final Duration espera;
}

/// Senha local do app: só **hash + salt** ficam no cofre (nunca a senha).
///
/// - PBKDF2-HMAC-SHA256 com salt aleatório de 16 bytes, rodando num isolate
///   para não travar a interface.
/// - 5 erros seguidos → espera de 30 s, persistida: fechar o app não zera.
class ServicoSenha {
  ServicoSenha(
    this._cofre, {
    DateTime Function()? agora,
    this.iteracoes = 120000,
    this.usarIsolate = true,
  }) : _agora = agora ?? DateTime.now;

  final ArmazenamentoSeguro _cofre;
  final DateTime Function() _agora;
  final int iteracoes;

  /// Em testes de widget (relógio falso) o isolate nunca completa: desligue.
  final bool usarIsolate;

  static const maxTentativas = 5;
  static const espera = Duration(seconds: 30);

  static const _kHash = 'senha_hash';
  static const _kSalt = 'senha_salt';
  static const _kIter = 'senha_iteracoes';
  static const _kFalhas = 'senha_falhas';
  static const _kBloqueadoAte = 'senha_bloqueado_ate';

  Future<bool> temSenha() async => (await _cofre.ler(_kHash)) != null;

  Future<void> definirSenha(String senha) async {
    final salt = _saltAleatorio();
    final hash = await _derivar(senha, salt, iteracoes, usarIsolate);
    await _cofre.gravar(_kSalt, base64Encode(salt));
    await _cofre.gravar(_kIter, '$iteracoes');
    await _cofre.gravar(_kHash, base64Encode(hash));
    await _zerarFalhas();
  }

  /// Tempo que ainda falta de bloqueio, ou `null` se pode tentar.
  Future<Duration?> bloqueioRestante() async {
    final texto = await _cofre.ler(_kBloqueadoAte);
    final ate = texto == null ? null : DateTime.tryParse(texto);
    if (ate == null) return null;
    final falta = ate.difference(_agora());
    return falta.isNegative || falta == Duration.zero ? null : falta;
  }

  Future<ResultadoLogin> verificar(String senha) async {
    final falta = await bloqueioRestante();
    if (falta != null) return LoginBloqueado(falta);

    final hashGuardado = await _cofre.ler(_kHash);
    final saltTexto = await _cofre.ler(_kSalt);
    if (hashGuardado == null || saltTexto == null) {
      return const LoginSenhaErrada(maxTentativas);
    }
    final iter = int.tryParse(await _cofre.ler(_kIter) ?? '') ?? iteracoes;
    final calculado =
        await _derivar(senha, base64Decode(saltTexto), iter, usarIsolate);

    if (_iguais(calculado, base64Decode(hashGuardado))) {
      await _zerarFalhas();
      return const LoginOk();
    }

    final falhas = (int.tryParse(await _cofre.ler(_kFalhas) ?? '') ?? 0) + 1;
    if (falhas >= maxTentativas) {
      await _cofre.gravar(_kFalhas, '0');
      await _cofre.gravar(_kBloqueadoAte, _agora().add(espera).toIso8601String());
      return const LoginBloqueado(espera);
    }
    await _cofre.gravar(_kFalhas, '$falhas');
    return LoginSenhaErrada(maxTentativas - falhas);
  }

  /// Troca a senha se [atual] estiver correta.
  Future<bool> trocarSenha(String atual, String nova) async {
    if (await verificar(atual) is! LoginOk) return false;
    await definirSenha(nova);
    return true;
  }

  Future<void> _zerarFalhas() async {
    await _cofre.gravar(_kFalhas, '0');
    await _cofre.apagar(_kBloqueadoAte);
  }

  static List<int> _saltAleatorio() {
    final r = Random.secure();
    return List<int>.generate(16, (_) => r.nextInt(256));
  }

  static Future<List<int>> _derivar(
    String senha,
    List<int> salt,
    int iter,
    bool isolate,
  ) {
    Future<List<int>> calcular() async {
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iter,
        bits: 256,
      );
      final chave = await pbkdf2.deriveKeyFromPassword(
        password: senha,
        nonce: salt,
      );
      return chave.extractBytes();
    }

    return isolate ? Isolate.run(calcular) : calcular();
  }

  /// Comparação em tempo constante.
  static bool _iguais(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
