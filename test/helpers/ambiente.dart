import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:lastro/data/auth/armazenamento_seguro.dart';
import 'package:lastro/data/auth/autenticador_biometrico.dart';
import 'package:lastro/data/auth/servico_senha.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/features/login/auth_controller.dart';

/// Ambiente de teste: banco em memória, cofre em memória e senha rápida.
class Ambiente {
  Ambiente({bool comSenha = false, String senha = 'segredo123'})
      : db = AppDatabase.forTesting(NativeDatabase.memory()),
        cofre = ArmazenamentoEmMemoria() {
    servico = ServicoSenha(cofre, iteracoes: 5, usarIsolate: false);
    _comSenha = comSenha;
    _senha = senha;
  }

  final AppDatabase db;
  final ArmazenamentoEmMemoria cofre;
  late final ServicoSenha servico;
  late final bool _comSenha;
  late final String _senha;

  /// Deve ser chamado dentro de `tester.runAsync` / `await` antes do app.
  Future<void> preparar() async {
    if (_comSenha) await servico.definirSenha(_senha);
  }

  List<Override> get overrides => [
        bancoProvider.overrideWithValue(db),
        armazenamentoSeguroProvider.overrideWithValue(cofre),
        servicoSenhaProvider.overrideWithValue(servico),
        autenticadorBiometricoProvider
            .overrideWithValue(AutenticadorBiometricoFalso()),
      ];

  Future<void> fechar() => db.close();
}
