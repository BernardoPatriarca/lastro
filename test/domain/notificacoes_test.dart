import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/alertas.dart';
import 'package:lastro/domain/notificacoes.dart';

String fmt(int c) => 'R\$ ${c ~/ 100}';

VencimentoAlerta v(String desc, DateTime d, {String chave = '', bool fatura = false, int valor = 10000}) =>
    VencimentoAlerta(descricao: desc, vencimento: d, valor: valor, ehFatura: fatura, chave: chave);

void main() {
  final agora = DateTime(2026, 3, 10, 8, 0);

  test('id estável: mesma chave dá o mesmo id; chaves diferentes diferem', () {
    expect(idEstavel('f12'), idEstavel('f12'));
    expect(idEstavel('f12'), isNot(idEstavel('f13')));
    expect(idEstavel('o12'), isNot(idEstavel('f12')));
    expect(idEstavel('qualquer'), inInclusiveRange(0, 0x7fffffff));
  });

  test('avisa N dias antes às 9h', () {
    final p = planejarNotificacoes(
      agora: agora,
      vencimentos: [v('Aluguel', DateTime(2026, 3, 15), chave: 'o1')],
      diasAntes: 1,
      formatarValor: fmt,
    );
    expect(p.single.quando, DateTime(2026, 3, 14, 9));
    expect(p.single.titulo, 'Aluguel vence amanhã');
    expect(p.single.corpo, 'R\$ 100');
  });

  test('no dia (0) e textos de 2 e 3 dias', () {
    List<NotificacaoPlanejada> com(int dias) => planejarNotificacoes(
          agora: agora,
          vencimentos: [v('Luz', DateTime(2026, 3, 20), chave: 'x')],
          diasAntes: dias,
          formatarValor: fmt,
        );
    expect(com(0).single.titulo, 'Luz vence hoje');
    expect(com(0).single.quando, DateTime(2026, 3, 20, 9));
    expect(com(2).single.titulo, 'Luz vence em 2 dias');
    expect(com(3).single.quando, DateTime(2026, 3, 17, 9));
  });

  test('fatura traz o lembrete de deixar saldo em conta', () {
    final p = planejarNotificacoes(
      agora: agora,
      vencimentos: [v('Fatura Cartão', DateTime(2026, 3, 17), chave: 'f1', fatura: true, valor: 250000)],
      diasAntes: 1,
      formatarValor: fmt,
    );
    expect(p.single.corpo, contains('R\$ 2500'));
    expect(p.single.corpo, contains('saldo em conta'));
  });

  test('só horários futuros: quem já passou das 9h do dia do aviso fica de fora', () {
    final depoisDas9 = DateTime(2026, 3, 10, 10);
    final p = planejarNotificacoes(
      agora: depoisDas9,
      vencimentos: [
        v('Hoje', DateTime(2026, 3, 11), chave: 'a'), // aviso era hoje 9h: passou
        v('Amanhã+1', DateTime(2026, 3, 12), chave: 'b'), // aviso amanhã 9h: vale
        v('Atrasada', DateTime(2026, 3, 1), chave: 'c'),
      ],
      diasAntes: 1,
      formatarValor: fmt,
    );
    expect(p.map((e) => e.titulo), ['Amanhã+1 vence amanhã']);
  });

  test('respeita o horizonte e o limite, do mais próximo ao mais distante', () {
    final muitos = [
      for (var i = 1; i <= 100; i++)
        v('Conta $i', DateTime(2026, 3, 10).add(Duration(days: i)), chave: 'k$i'),
    ];
    final p = planejarNotificacoes(
      agora: agora,
      vencimentos: muitos,
      diasAntes: 0,
      formatarValor: fmt,
      horizonteDias: 45,
      limite: 20,
    );
    expect(p.length, 20);
    expect(p.first.titulo, 'Conta 1 vence hoje');
    final todas = planejarNotificacoes(
      agora: agora, vencimentos: muitos, diasAntes: 0, formatarValor: fmt, limite: 1000,
    );
    expect(todas.length, 44); // o aviso de 24/04 às 9h passa de 45 dias a contar de 10/03 às 8h
    expect([...todas.map((e) => e.quando)]..sort(), todas.map((e) => e.quando).toList());
  });

  test('sem chave, o id é derivado da descrição e do dia (estável)', () {
    final a = planejarNotificacoes(
      agora: agora, vencimentos: [v('Água', DateTime(2026, 3, 20))], diasAntes: 1, formatarValor: fmt);
    final b = planejarNotificacoes(
      agora: agora, vencimentos: [v('Água', DateTime(2026, 3, 20))], diasAntes: 1, formatarValor: fmt);
    expect(a.single.id, b.single.id);
  });
}
