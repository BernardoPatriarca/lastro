import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/auth/armazenamento_seguro.dart';
import 'package:lastro/data/auth/servico_senha.dart';

void main() {
  late ArmazenamentoEmMemoria cofre;
  late DateTime agora;
  late ServicoSenha s;

  setUp(() {
    cofre = ArmazenamentoEmMemoria();
    agora = DateTime(2026, 3, 1, 12);
    s = ServicoSenha(cofre, agora: () => agora, iteracoes: 10);
  });

  test('guarda só hash e salt, nunca a senha', () async {
    expect(await s.temSenha(), isFalse);
    await s.definirSenha('minha-senha');
    expect(await s.temSenha(), isTrue);
    expect(cofre.dados.values.any((v) => v.contains('minha-senha')), isFalse);
    expect(cofre.dados.keys, containsAll(['senha_hash', 'senha_salt']));
  });

  test('mesma senha gera hashes diferentes (salt aleatório)', () async {
    await s.definirSenha('igual');
    final h1 = cofre.dados['senha_hash'];
    await s.definirSenha('igual');
    expect(cofre.dados['senha_hash'], isNot(h1));
  });

  test('senha certa entra, errada conta tentativas', () async {
    await s.definirSenha('certa123');
    expect(await s.verificar('certa123'), isA<LoginOk>());
    final r = await s.verificar('errada');
    expect(r, isA<LoginSenhaErrada>());
    expect((r as LoginSenhaErrada).tentativasRestantes, 4);
  });

  test('acerto zera o contador de erros', () async {
    await s.definirSenha('certa123');
    await s.verificar('x');
    await s.verificar('y');
    await s.verificar('certa123');
    final r = await s.verificar('z') as LoginSenhaErrada;
    expect(r.tentativasRestantes, 4);
  });

  test('5 erros bloqueiam por 30 s e depois liberam', () async {
    await s.definirSenha('certa123');
    for (var i = 0; i < 4; i++) {
      expect(await s.verificar('x'), isA<LoginSenhaErrada>());
    }
    final quinto = await s.verificar('x');
    expect(quinto, isA<LoginBloqueado>());
    expect((quinto as LoginBloqueado).espera, const Duration(seconds: 30));

    // durante o bloqueio, até a senha certa é recusada
    expect(await s.verificar('certa123'), isA<LoginBloqueado>());

    agora = agora.add(const Duration(seconds: 31));
    expect(await s.bloqueioRestante(), isNull);
    expect(await s.verificar('certa123'), isA<LoginOk>());
  });

  test('o bloqueio sobrevive a recriar o serviço (reiniciar o app)', () async {
    await s.definirSenha('certa123');
    for (var i = 0; i < 5; i++) {
      await s.verificar('x');
    }
    final novo = ServicoSenha(cofre, agora: () => agora, iteracoes: 10);
    expect(await novo.bloqueioRestante(), isNotNull);
  });

  test('trocar senha exige a atual', () async {
    await s.definirSenha('antiga123');
    expect(await s.trocarSenha('errada', 'nova12345'), isFalse);
    expect(await s.trocarSenha('antiga123', 'nova12345'), isTrue);
    expect(await s.verificar('antiga123'), isA<LoginSenhaErrada>());
    expect(await s.verificar('nova12345'), isA<LoginOk>());
  });

  test('funciona também com o isolate ligado (caminho real)', () async {
    final real = ServicoSenha(cofre, iteracoes: 1000);
    await real.definirSenha('isolado');
    expect(await real.verificar('isolado'), isA<LoginOk>());
  });
}
