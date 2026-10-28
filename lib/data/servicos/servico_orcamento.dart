import '../../domain/competencia.dart';
import '../../domain/orcamento.dart';
import '../banco.dart';

/// Limites mensais por categoria (V2).
class ServicoOrcamento {
  ServicoOrcamento(this._db);
  final AppDatabase _db;

  /// Define o limite de [categoriaId] no mês. Limite nulo ou ≤ 0 remove.
  Future<void> definirLimite(int categoriaId, Competencia mes, int? limite) {
    if (limite == null || limite <= 0) {
      return _db.investimentosDao.excluirOrcamento(categoriaId, mes.chave).then((_) {});
    }
    return _db.investimentosDao.definirOrcamento(categoriaId, mes.chave, limite);
  }

  /// "Copiar do mês anterior": traz os limites que ainda não existem no mês.
  /// Devolve quantos foram copiados.
  Future<int> copiarDoMesAnterior(Competencia mes) async {
    final dao = _db.investimentosDao;
    final anterior = {
      for (final o in await dao.orcamentosDe(mes.somarMeses(-1).chave)) o.categoriaId: o.limite,
    };
    final atual = {
      for (final o in await dao.orcamentosDe(mes.chave)) o.categoriaId: o.limite,
    };
    final novos = limitesACopiar(mesAnterior: anterior, mesAtual: atual);
    for (final e in novos.entries) {
      await dao.definirOrcamento(e.key, mes.chave, e.value);
    }
    return novos.length;
  }
}
