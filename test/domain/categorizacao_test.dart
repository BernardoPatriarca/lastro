import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/categorizacao.dart';
import 'package:lastro/domain/texto.dart';

void main() {
  group('normalização de texto', () {
    test('tira acentos, caixa e espaços repetidos', () {
      expect(normalizarTexto('  PADARIA   São  João  '), 'padaria sao joao');
      expect(normalizarTexto('Ação Café Ç'), 'acao cafe c');
    });
  });

  group('categoria sugerida por regras', () {
    const regras = [
      RegraSimples(id: 1, padrao: 'uber', categoriaId: 10),
      RegraSimples(id: 2, padrao: 'ifood', categoriaId: 20),
      RegraSimples(id: 3, padrao: 'Padaria', categoriaId: 30),
    ];

    test('casa sem diferenciar acento nem maiúsculas', () {
      expect(categoriaSugerida('UBER *TRIP 1234', regras), 10);
      expect(categoriaSugerida('Pagamento iFood', regras), 20);
      expect(categoriaSugerida('PADARIA SÃO JOÃO', regras), 30);
    });

    test('sem regra que case devolve nulo', () {
      expect(categoriaSugerida('Loja da esquina', regras), isNull);
      expect(categoriaSugerida('', regras), isNull);
      expect(categoriaSugerida('qualquer', const []), isNull);
    });

    test('padrão com acento casa com descrição sem acento', () {
      const r = [RegraSimples(id: 1, padrao: 'Farmácia', categoriaId: 5)];
      expect(categoriaSugerida('FARMACIA POPULAR', r), 5);
    });

    test('maior prioridade vence', () {
      const r = [
        RegraSimples(id: 1, padrao: 'mercado', categoriaId: 1, prioridade: 0),
        RegraSimples(id: 2, padrao: 'mercado livre', categoriaId: 2, prioridade: 0),
        RegraSimples(id: 3, padrao: 'livre', categoriaId: 3, prioridade: 5),
      ];
      expect(categoriaSugerida('MERCADO LIVRE', r), 3);
    });

    test('empate de prioridade: padrão mais específico (mais longo) vence', () {
      const r = [
        RegraSimples(id: 1, padrao: 'mercado', categoriaId: 1),
        RegraSimples(id: 2, padrao: 'mercado livre', categoriaId: 2),
      ];
      expect(categoriaSugerida('Compra MERCADO LIVRE', r), 2);
      expect(categoriaSugerida('Compra mercado central', r), 1);
    });

    test('empate total: a regra mais antiga vence', () {
      const r = [
        RegraSimples(id: 7, padrao: 'loja', categoriaId: 70),
        RegraSimples(id: 3, padrao: 'loja', categoriaId: 30),
      ];
      expect(categoriaSugerida('loja x', r), 30);
    });

    test('padrão vazio nunca casa', () {
      const r = [RegraSimples(id: 1, padrao: '   ', categoriaId: 1)];
      expect(categoriaSugerida('qualquer coisa', r), isNull);
    });
  });

  group('sugestão de padrão', () {
    test('tira números, datas e palavras de ruído', () {
      expect(sugerirPadrao('COMPRA CARTAO MERCADO LIVRE 12/03'), 'mercado livre');
      expect(sugerirPadrao('PIX ENVIADO - Padaria São João 0042'), 'padaria sao');
      expect(sugerirPadrao('UBER *TRIP 9876'), 'uber trip');
    });

    test('só ruído: devolve a descrição normalizada', () {
      expect(sugerirPadrao('PIX 123'), 'pix 123');
    });

    test('uma palavra só', () {
      expect(sugerirPadrao('Netflix'), 'netflix');
    });
  });
}
