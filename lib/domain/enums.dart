// Enums do domínio. São gravados no banco pelo `name` (texto legível).

enum TipoConta { corrente, poupanca, carteira }

enum TipoCategoria { gasto, ganho }

enum TipoLancamento {
  gasto,
  ganho,
  transferencia,
  aporte,
  resgate,
  pagamentoFatura,
  ajusteSaldo,
}

enum FormaPagamento { debito, pix, dinheiro, boleto, credito }

enum OrigemLancamento { manual, importado }

enum StatusFatura { aberta, fechada, paga }

enum TipoCompromisso { recorrente, parcelado }

enum StatusOcorrencia { pendente, paga }

enum TipoInvestimento { reserva, cdb, tesouro, acoes, fiis, cripto, outro }

enum TipoMovimentoInvestimento { aporte, resgate, atualizacaoSaldo }

/// Como parcelas futuras entram no "Crédito seguro" (CLAUDE.md 5.1).
enum ModoParcelados { rigido, parcela }

/// O que fazer quando uma compra no crédito estoura o crédito seguro.
enum ComportamentoEstouro { avisar, confirmar, bloquear }

extension TipoContaRotulo on TipoConta {
  String get rotulo => switch (this) {
        TipoConta.corrente => 'Conta corrente',
        TipoConta.poupanca => 'Poupança',
        TipoConta.carteira => 'Carteira',
      };
}

extension FormaPagamentoRotulo on FormaPagamento {
  String get rotulo => switch (this) {
        FormaPagamento.debito => 'Débito',
        FormaPagamento.pix => 'Pix',
        FormaPagamento.dinheiro => 'Dinheiro',
        FormaPagamento.boleto => 'Boleto',
        FormaPagamento.credito => 'Crédito',
      };
}

extension TipoLancamentoRotulo on TipoLancamento {
  String get rotulo => switch (this) {
        TipoLancamento.gasto => 'Gasto',
        TipoLancamento.ganho => 'Ganho',
        TipoLancamento.transferencia => 'Transferência',
        TipoLancamento.aporte => 'Aporte',
        TipoLancamento.resgate => 'Resgate',
        TipoLancamento.pagamentoFatura => 'Pagamento de fatura',
        TipoLancamento.ajusteSaldo => 'Ajuste de saldo',
      };
}

extension TipoInvestimentoRotulo on TipoInvestimento {
  String get rotulo => switch (this) {
        TipoInvestimento.reserva => 'Reserva de emergência',
        TipoInvestimento.cdb => 'CDB',
        TipoInvestimento.tesouro => 'Tesouro Direto',
        TipoInvestimento.acoes => 'Ações',
        TipoInvestimento.fiis => 'FIIs',
        TipoInvestimento.cripto => 'Cripto',
        TipoInvestimento.outro => 'Outro',
      };
}
