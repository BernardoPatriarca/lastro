import 'package:drift/drift.dart';

import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../banco.dart';
import 'servico_cartao.dart' show OperacaoInvalida;
import 'servico_lancamentos.dart';

/// Investimentos: aportes, resgates e atualização de saldo (V2).
///
/// Aporte e resgate são **lançamentos** (mexem no saldo da conta) ligados a um
/// movimento do investimento; "atualizar saldo" é só um movimento (o
/// rendimento não passa pela conta).
class ServicoInvestimento {
  ServicoInvestimento(this._db);
  final AppDatabase _db;

  Future<int> criar({required String nome, required TipoInvestimento tipo}) =>
      _db.investimentosDao.inserirInvestimento(
        InvestimentosCompanion.insert(nome: nome.trim(), tipo: tipo),
      );

  Future<void> atualizar(Investimento i) =>
      _db.investimentosDao.atualizarInvestimento(i);

  /// Aporte: sai da [contaId] para o investimento.
  Future<int> aportar({
    required int contaId,
    required int valor,
    required DateTime data,
    int? investimentoId,
    String descricao = '',
  }) =>
      _movimentar(
        tipo: TipoLancamento.aporte,
        movimento: TipoMovimentoInvestimento.aporte,
        contaId: contaId,
        valor: valor,
        data: data,
        investimentoId: investimentoId,
        descricao: descricao,
      );

  /// Resgate: volta do investimento para a [contaId].
  Future<int> resgatar({
    required int contaId,
    required int valor,
    required DateTime data,
    int? investimentoId,
    String descricao = '',
  }) =>
      _movimentar(
        tipo: TipoLancamento.resgate,
        movimento: TipoMovimentoInvestimento.resgate,
        contaId: contaId,
        valor: valor,
        data: data,
        investimentoId: investimentoId,
        descricao: descricao,
      );

  Future<int> _movimentar({
    required TipoLancamento tipo,
    required TipoMovimentoInvestimento movimento,
    required int contaId,
    required int valor,
    required DateTime data,
    required String descricao,
    int? investimentoId,
  }) {
    if (valor <= 0) throw const OperacaoInvalida('Informe um valor maior que zero.');
    return _db.transaction(() async {
      final lancId = await ServicoLancamentos(_db).registrar(
        tipo: tipo,
        valor: valor,
        data: data,
        descricao: descricao,
        contaId: contaId,
        investimentoId: investimentoId,
      );
      if (investimentoId != null) {
        await _db.investimentosDao.inserirMovimento(MovimentosInvestimentoCompanion.insert(
          investimentoId: investimentoId,
          tipo: movimento,
          valor: valor,
          data: soData(data),
          lancamentoId: Value(lancId),
        ));
      }
      return lancId;
    });
  }

  /// "Atualizar saldo": informa quanto o investimento vale hoje (rendimento).
  Future<void> atualizarSaldo({
    required int investimentoId,
    required int saldo,
    required DateTime data,
  }) async {
    if (saldo < 0) throw const OperacaoInvalida('O saldo não pode ser negativo.');
    await _db.investimentosDao.inserirMovimento(MovimentosInvestimentoCompanion.insert(
      investimentoId: investimentoId,
      tipo: TipoMovimentoInvestimento.atualizacaoSaldo,
      valor: saldo,
      data: soData(data),
    ));
  }

  /// Exclui um movimento. Aporte/resgate levam o lançamento junto (a conta
  /// volta ao que era).
  Future<void> excluirMovimento(MovimentoInvestimento m) async {
    if (m.lancamentoId != null) {
      await ServicoLancamentos(_db).excluir(m.lancamentoId!);
    } else {
      await _db.investimentosDao.excluirMovimento(m.id);
    }
  }

  /// Exclui o investimento e seus movimentos; lançamentos de aporte/resgate
  /// ficam (o dinheiro já saiu/entrou na conta), só perdem o vínculo.
  Future<void> excluirInvestimento(int id) async {
    await _db.transaction(() async {
      await _db.investimentosDao.excluirMetasDe(id);
      await (_db.update(_db.lancamentos)..where((l) => l.investimentoId.equals(id)))
          .write(const LancamentosCompanion(investimentoId: Value(null)));
      await (_db.delete(_db.movimentosInvestimento)
            ..where((m) => m.investimentoId.equals(id)))
          .go();
      await (_db.delete(_db.investimentos)..where((i) => i.id.equals(id))).go();
    });
  }

  // ---- metas ----

  Future<int> criarMeta({
    required String nome,
    required int valorAlvo,
    required DateTime prazo,
    int? investimentoId,
  }) =>
      _db.investimentosDao.inserirMeta(MetasCompanion.insert(
        nome: nome.trim(),
        valorAlvo: valorAlvo,
        prazo: soData(prazo),
        investimentoId: Value(investimentoId),
      ));

  Future<void> atualizarMeta(Meta m) => _db.investimentosDao.atualizarMeta(m);

  Future<void> excluirMeta(int id) => _db.investimentosDao.excluirMeta(id);
}
