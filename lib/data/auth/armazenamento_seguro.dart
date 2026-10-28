import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cofre de pequenos segredos (hash e salt da senha, tentativas erradas).
abstract interface class ArmazenamentoSeguro {
  Future<String?> ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> apagar(String chave);
}

/// Implementação real: Android Keystore via flutter_secure_storage.
class ArmazenamentoSeguroPlataforma implements ArmazenamentoSeguro {
  ArmazenamentoSeguroPlataforma([FlutterSecureStorage? armazenamento])
      : _s = armazenamento ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  @override
  Future<String?> ler(String chave) => _s.read(key: chave);
  @override
  Future<void> gravar(String chave, String valor) =>
      _s.write(key: chave, value: valor);
  @override
  Future<void> apagar(String chave) => _s.delete(key: chave);
}

/// Para testes.
class ArmazenamentoEmMemoria implements ArmazenamentoSeguro {
  final Map<String, String> dados = {};

  @override
  Future<String?> ler(String chave) async => dados[chave];
  @override
  Future<void> gravar(String chave, String valor) async => dados[chave] = valor;
  @override
  Future<void> apagar(String chave) async => dados.remove(chave);
}
