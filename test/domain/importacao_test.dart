import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/importacao/csv_import.dart';
import 'package:lastro/domain/importacao/leitura.dart';
import 'package:lastro/domain/importacao/ofx.dart';
import 'package:lastro/domain/importacao/transacao_importada.dart';

String fixture(String nome) => File('test/fixtures/$nome').readAsStringSync();

void main() {
  group('valores em reais → centavos (sem double)', () {
    test('formatos brasileiros e internacionais', () {
      expect(parseCentavos('1.234,56'), 123456);
      expect(parseCentavos('1234.56'), 123456);
      expect(parseCentavos('1,234.56'), 123456);
      expect(parseCentavos('12,5'), 1250);
      expect(parseCentavos('12'), 1200);
      expect(parseCentavos('0,05'), 5);
      expect(parseCentavos('R\$ 30,00'), 3000);
      expect(parseCentavos('4500.00'), 450000);
    });

    test('sinais: -, parênteses e sinal no fim', () {
      expect(parseCentavos('-389.90'), -38990);
      expect(parseCentavos('(30,00)'), -3000);
      expect(parseCentavos('30,00-'), -3000);
      expect(parseCentavos('+15,00'), 1500);
    });

    test('milhar sem decimais', () {
      expect(parseCentavos('1.234.567'), 123456700);
      expect(parseCentavos('12.345'), 1234500);
    });

    test('arredonda a terceira casa e rejeita lixo', () {
      expect(parseCentavos('0.126'), 13);
      expect(parseCentavos(''), isNull);
      expect(parseCentavos('abc'), isNull);
      expect(parseCentavos('1,2,3a'), isNull);
    });
  });

  group('datas', () {
    test('vários formatos', () {
      expect(parseDataComFormato('05/03/2026', 'dd/MM/yyyy'), DateTime(2026, 3, 5));
      expect(parseDataComFormato('05/03/26', 'dd/MM/yy'), DateTime(2026, 3, 5));
      expect(parseDataComFormato('2026-03-05', 'yyyy-MM-dd'), DateTime(2026, 3, 5));
      expect(parseDataComFormato('03/05/2026', 'MM/dd/yyyy'), DateTime(2026, 3, 5));
      expect(parseDataComFormato('05.03.2026', 'dd.MM.yyyy'), DateTime(2026, 3, 5));
      expect(parseDataComFormato('05/03/2026 14:30', 'dd/MM/yyyy'), DateTime(2026, 3, 5));
      expect(parseDataComFormato('20260305', 'yyyyMMdd'), DateTime(2026, 3, 5));
    });

    test('rejeita datas impossíveis', () {
      expect(parseDataComFormato('31/02/2026', 'dd/MM/yyyy'), isNull);
      expect(parseDataComFormato('abc', 'dd/MM/yyyy'), isNull);
      expect(parseDataComFormato('13/13/2026', 'dd/MM/yyyy'), isNull);
    });
  });

  group('texto do arquivo', () {
    test('UTF-8 válido é mantido; BOM é removido', () {
      final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...'Ação'.codeUnits.map((c) => c)]);
      // "Ação" em UTF-8 de verdade:
      final utf = Uint8List.fromList([0xEF, 0xBB, 0xBF, 0x41, 0xC3, 0xA7, 0xC3, 0xA3, 0x6F]);
      expect(decodificarTexto(utf), 'Ação');
      expect(bytes.isNotEmpty, isTrue);
    });

    test('Latin-1 (padrão de bancos) é detectado', () {
      final latin = Uint8List.fromList([0x41, 0xE7, 0xE3, 0x6F]); // "Ação"
      expect(decodificarTexto(latin), 'Ação');
    });
  });

  group('OFX', () {
    test('lê o SGML de conta: transações, saldo e conta', () {
      final e = lerOfx(fixture('extrato_conta_sgml.ofx'));
      expect(e.ehCartao, isFalse);
      expect(e.transacoes.length, 5);
      expect(e.idConta, '00012345-6');
      expect(e.saldoFinal, 373160);
      expect(e.dataSaldo, DateTime(2026, 3, 31));

      final sal = e.transacoes[0];
      expect(sal.data, DateTime(2026, 3, 5));
      expect(sal.valor, 450000);
      expect(sal.fitid, '2026030500001');
      expect(sal.descricao, 'SALARIO EMPRESA FICTICIA');

      expect(e.transacoes[1].valor, -38990);
      expect(e.transacoes[1].descricao, 'COMPRA DEBITO - SUPERMERCADO BOM PRECO');
      expect(e.transacoes[2].valor, -120000);
      // vírgula decimal e entidade XML
      expect(e.transacoes[3].valor, -2850);
      expect(e.transacoes[3].descricao, 'PIX ENVIADO PADARIA SAO JOAO & CIA');
    });

    test('lê o XML de cartão de crédito', () {
      final e = lerOfx(fixture('fatura_cartao_xml.ofx'));
      expect(e.ehCartao, isTrue);
      expect(e.transacoes.length, 3);
      expect(e.transacoes.first.valor, -8990);
      expect(e.transacoes.first.fitid, 'cc-0001');
      expect(e.transacoes.last.valor, 50000); // pagamento recebido (crédito)
      expect(e.saldoFinal, -13490);
    });

    test('pareceOfx reconhece os dois formatos e rejeita CSV', () {
      expect(pareceOfx(fixture('extrato_conta_sgml.ofx')), isTrue);
      expect(pareceOfx(fixture('fatura_cartao_xml.ofx')), isTrue);
      expect(pareceOfx(fixture('extrato_conta.csv')), isFalse);
    });

    test('arquivo sem transações devolve lista vazia, sem quebrar', () {
      final e = lerOfx('<OFX><BANKMSGSRSV1></BANKMSGSRSV1></OFX>');
      expect(e.transacoes, isEmpty);
      expect(e.saldoFinal, isNull);
    });

    test('ignora transação sem data ou valor', () {
      final e = lerOfx('<OFX><STMTTRN><TRNAMT>10.00<FITID>1</STMTTRN>'
          '<STMTTRN><DTPOSTED>20260101<TRNAMT>-5.00<FITID>2</STMTTRN></OFX>');
      expect(e.transacoes.length, 1);
      expect(e.transacoes.single.fitid, '2');
    });
  });

  group('CSV', () {
    test('detecta separador e lê campo entre aspas com vírgula', () {
      final texto = fixture('extrato_conta.csv');
      expect(detectarSeparador(texto), ';');
      final linhas = lerCsv(texto);
      expect(linhas.first, ['Data', 'Descrição', 'Valor', 'Tipo']);
      expect(linhas.any((l) => l[1] == 'PADARIA, SAO JOAO'), isTrue);
      expect(detectarSeparador(fixture('fatura_cartao.csv')), ',');
    });

    test('sugere o mapeamento pelos nomes das colunas', () {
      final m = sugerirMapeamento(['Data', 'Descrição', 'Valor', 'Tipo'], separador: ';');
      expect((m.colunaData, m.colunaDescricao, m.colunaValor, m.colunaTipo), (0, 1, 2, 3));
      final g = sugerirMapeamento(['date', 'title', 'amount']);
      expect((g.colunaData, g.colunaDescricao, g.colunaValor), (0, 1, 2));
      expect(g.colunaTipo, isNull);
    });

    test('converte extrato de conta usando a coluna de tipo e ignora linhas inválidas',
        () {
      final linhas = lerCsv(fixture('extrato_conta.csv'));
      final r = converterCsv(
        linhas,
        const MapeamentoCsv(
          colunaData: 0,
          colunaDescricao: 1,
          colunaValor: 2,
          colunaTipo: 3,
        ),
      );
      expect(r.ignoradas, 1);
      expect(r.transacoes.length, 5);
      expect(r.transacoes[0].valor, 450000); // Crédito
      expect(r.transacoes[1].valor, -38990); // Débito (valor positivo no arquivo)
      expect(r.transacoes[2].valor, -120000); // sem tipo: vale o sinal
      expect(r.transacoes[3].data, DateTime(2026, 3, 10));
    });

    test('fatura de cartão: positivo é gasto', () {
      final linhas = lerCsv(fixture('fatura_cartao.csv'));
      final r = converterCsv(
        linhas,
        const MapeamentoCsv(
          colunaData: 0,
          colunaDescricao: 1,
          colunaValor: 2,
          formatoData: 'yyyy-MM-dd',
          separador: ',',
          positivoEhGasto: true,
        ),
      );
      expect(r.transacoes.map((t) => t.valor), [-8990, -4500, 50000]);
    });

    test('sem cabeçalho não pula a primeira linha', () {
      final r = converterCsv(
        [
          ['05/03/2026', 'A', '10,00'],
        ],
        const MapeamentoCsv(
            colunaData: 0, colunaDescricao: 1, colunaValor: 2, temCabecalho: false),
      );
      expect(r.transacoes.length, 1);
    });
  });

  group('deduplicação (chave de importação)', () {
    TransacaoImportada t(String desc, int valor, DateTime d, {String? fitid}) =>
        TransacaoImportada(data: d, descricao: desc, valor: valor, fitid: fitid);

    test('usa o FITID quando existe', () {
      final r = atribuirChaves([t('x', -100, DateTime(2026, 3, 1), fitid: 'ABC')],
          prefixo: 'c1');
      expect(r.single.chave, 'c1:f:ABC');
    });

    test('sem FITID: data + valor + descrição normalizada', () {
      final r = atribuirChaves(
          [t('  Padaria SÃO João ', -2850, DateTime(2026, 3, 10))],
          prefixo: 'c1');
      expect(r.single.chave, 'c1:h:20260310|-2850|padaria sao joao');
    });

    test('contas diferentes não colidem', () {
      final a = atribuirChaves([t('x', 1, DateTime(2026), fitid: '1')], prefixo: 'c1');
      final b = atribuirChaves([t('x', 1, DateTime(2026), fitid: '1')], prefixo: 'c2');
      expect(a.single.chave, isNot(b.single.chave));
    });

    test('iguais no mesmo arquivo viram #2, #3 e a numeração é estável', () {
      final lista = [
        t('Café', -500, DateTime(2026, 3, 1)),
        t('Café', -500, DateTime(2026, 3, 1)),
        t('Café', -500, DateTime(2026, 3, 1)),
      ];
      final a = atribuirChaves(lista, prefixo: 'c1');
      final b = atribuirChaves(lista, prefixo: 'c1');
      expect(a.map((e) => e.chave).toSet().length, 3);
      expect(a.map((e) => e.chave).toList(), b.map((e) => e.chave).toList());
      expect(a[1].chave.endsWith('#2'), isTrue);
    });

    test('reimportar o mesmo arquivo marca tudo como duplicada', () {
      final primeira = atribuirChaves(lerOfx(fixture('extrato_conta_sgml.ofx')).transacoes,
          prefixo: 'c1');
      final existentes = {for (final e in primeira) e.chave};
      final segunda = atribuirChaves(lerOfx(fixture('extrato_conta_sgml.ofx')).transacoes,
          prefixo: 'c1');
      expect(chavesDuplicadas(segunda, existentes).length, 5);
      // arquivo com uma transação nova: só ela não é duplicada
      final nova = [
        ...segunda,
        ...atribuirChaves([t('Nova', -1, DateTime(2026, 4, 1), fitid: 'N1')], prefixo: 'c1'),
      ];
      expect(chavesDuplicadas(nova, existentes).length, 5);
    });
  });

  group('forma de pagamento provável', () {
    test('pelo texto da descrição', () {
      expect(inferirForma('PIX ENVIADO FULANO'), FormaPagamento.pix);
      expect(inferirForma('BOLETO ALUGUEL'), FormaPagamento.boleto);
      expect(inferirForma('SAQUE 24H'), FormaPagamento.dinheiro);
      expect(inferirForma('COMPRA DEBITO MERCADO'), FormaPagamento.debito);
    });
  });

  group('casar com contas pendentes (CLAUDE.md 7)', () {
    TransacaoImportada s(int valor, DateTime d) =>
        TransacaoImportada(data: d, descricao: 'x', valor: valor);

    test('mesmo valor e data até ±5 dias casa', () {
      final m = casarComOcorrencias(
        [s(-120000, DateTime(2026, 3, 7))],
        [OcorrenciaPendenteSimples(id: 9, valor: 120000, vencimento: DateTime(2026, 3, 5))],
      );
      expect(m, {0: 9});
    });

    test('fora da tolerância, valor diferente ou entrada não casam', () {
      final oc = [OcorrenciaPendenteSimples(id: 1, valor: 120000, vencimento: DateTime(2026, 3, 5))];
      expect(casarComOcorrencias([s(-120000, DateTime(2026, 3, 11))], oc), isEmpty);
      expect(casarComOcorrencias([s(-120001, DateTime(2026, 3, 5))], oc), isEmpty);
      expect(casarComOcorrencias([s(120000, DateTime(2026, 3, 5))], oc), isEmpty);
      expect(casarComOcorrencias([s(-120000, DateTime(2026, 3, 10))], oc), {0: 1}); // 5 dias
    });

    test('cada ocorrência é usada uma vez, pela mais próxima', () {
      final m = casarComOcorrencias(
        [s(-5000, DateTime(2026, 3, 3)), s(-5000, DateTime(2026, 3, 20))],
        [
          OcorrenciaPendenteSimples(id: 1, valor: 5000, vencimento: DateTime(2026, 3, 2)),
          OcorrenciaPendenteSimples(id: 2, valor: 5000, vencimento: DateTime(2026, 3, 21)),
        ],
      );
      expect(m, {0: 1, 1: 2});
    });
  });
}
