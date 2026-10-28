import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/importacao/transacao_importada.dart';
import '../../domain/saldo.dart';
import '../banco.dart';
import 'servico_cartao.dart';
import 'servico_compromisso.dart';
import 'servico_lancamentos.dart';

/// Linha já revisada, pronta para virar lançamento.
class LinhaParaImportar {
  const LinhaParaImportar({
    required this.transacao,
    this.categoriaId,
    this.ocorrenciaId,
  });

  final TransacaoImportada transacao;
  final int? categoriaId;

  /// Se preenchido, o lançamento criado marca esta conta fixa como paga.
  final int? ocorrenciaId;
}

class ResumoImportacao {
  const ResumoImportacao({
    this.importadas = 0,
    this.vinculadas = 0,
    this.ignoradas = 0,
  });

  final int importadas;
  final int vinculadas;
  final int ignoradas;
}

/// Grava as transações revisadas como lançamentos (origem `importado`).
class ServicoImportacao {
  ServicoImportacao(this._db);
  final AppDatabase _db;

  /// Chaves de importação já gravadas (para marcar duplicadas).
  Future<Set<String>> chavesExistentes() => _db.lancamentosDao.chavesImportacao();

  /// Quantos lançamentos importados a conta já tem (0 = primeira importação).
  Future<int> importadosDaConta(int contaId) async {
    final lancs = await _db.lancamentosDao.todos();
    return lancs
        .where((l) => l.origem == OrigemLancamento.importado && l.contaId == contaId)
        .length;
  }

  /// Saldo atual da conta (lançamentos até hoje), calculado direto do banco.
  Future<int> saldoAtual(Conta conta) async {
    final hoje = DateTime.now();
    final fim = DateTime(hoje.year, hoje.month, hoje.day);
    final lancs = await _db.lancamentosDao.todos();
    return calcularSaldoConta(
      contaId: conta.id,
      saldoInicial: conta.saldoInicial,
      dataSaldoInicial: conta.dataSaldoInicial,
      movimentos: [
        for (final l in lancs)
          if (!l.data.isAfter(fim))
            MovimentoSaldo(
              tipo: l.tipo,
              valor: l.valor,
              data: l.data,
              forma: l.formaPagamento,
              contaId: l.contaId,
              contaDestinoId: l.contaDestinoId,
            ),
      ],
    );
  }

  /// Importa para uma **conta**: saídas viram gasto (forma inferida pelo
  /// texto), entradas viram ganho. Linhas com [LinhaParaImportar.ocorrenciaId]
  /// marcam a conta fixa como paga em vez de ficar soltas.
  Future<ResumoImportacao> importarParaConta(
    int contaId,
    List<LinhaParaImportar> linhas,
  ) {
    final lanc = ServicoLancamentos(_db);
    final compromissos = ServicoCompromisso(_db);
    return _db.transaction(() async {
      var importadas = 0, vinculadas = 0;
      for (final l in linhas) {
        final t = l.transacao;
        final id = await lanc.registrar(
          tipo: t.ehSaida ? TipoLancamento.gasto : TipoLancamento.ganho,
          valor: t.valor.abs(),
          data: t.data,
          descricao: t.descricao,
          categoriaId: l.categoriaId,
          forma: t.ehSaida ? inferirForma(t.descricao) : null,
          contaId: contaId,
          origem: OrigemLancamento.importado,
          chaveImportacao: t.chave,
        );
        importadas++;
        if (l.ocorrenciaId != null) {
          final oc = await _db.compromissosDao.ocorrencia(l.ocorrenciaId!);
          final criado = await _db.lancamentosDao.obter(id);
          if (oc != null && criado != null && oc.status == StatusOcorrencia.pendente) {
            await compromissos.vincularLancamento(oc, criado);
            vinculadas++;
          }
        }
      }
      return ResumoImportacao(importadas: importadas, vinculadas: vinculadas);
    });
  }

  /// Importa uma **fatura de cartão**: cada saída vira compra à vista no
  /// crédito, na fatura do ciclo certo. Entradas (estornos, "pagamento
  /// recebido") são ignoradas: o pagamento já é lançado ao pagar a fatura.
  Future<ResumoImportacao> importarParaCartao(
    Cartao cartao,
    List<LinhaParaImportar> linhas,
  ) {
    final servico = ServicoCartao(_db);
    return _db.transaction(() async {
      var importadas = 0, ignoradas = 0;
      for (final l in linhas) {
        final t = l.transacao;
        if (!t.ehSaida) {
          ignoradas++;
          continue;
        }
        await servico.registrarCompra(
          cartao: cartao,
          valorTotal: t.valor.abs(),
          parcelas: 1,
          data: t.data,
          descricao: t.descricao,
          categoriaId: l.categoriaId,
          origem: OrigemLancamento.importado,
          chaveImportacao: t.chave,
        );
        importadas++;
      }
      return ResumoImportacao(importadas: importadas, ignoradas: ignoradas);
    });
  }

  /// Salva (ou atualiza, pelo nome) um mapeamento de colunas de CSV.
  Future<void> salvarMapeamento({
    required String nome,
    required String separador,
    required bool temCabecalho,
    required int colunaData,
    required int colunaDescricao,
    required int colunaValor,
    int? colunaTipo,
    required String formatoData,
    required bool positivoEhGasto,
  }) =>
      _db.mapeamentosDao.salvar(MapeamentosCsvCompanion.insert(
        nome: nome.trim(),
        colunaData: colunaData,
        colunaDescricao: colunaDescricao,
        colunaValor: colunaValor,
        separador: Value(separador),
        temCabecalho: Value(temCabecalho),
        colunaTipo: Value(colunaTipo),
        formatoData: Value(formatoData),
        positivoEhGasto: Value(positivoEhGasto),
      ));
}
