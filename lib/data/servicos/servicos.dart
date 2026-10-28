import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'servico_backup.dart';
import 'servico_cartao.dart';
import 'servico_compromisso.dart';
import 'servico_importacao.dart';
import 'servico_investimento.dart';
import 'servico_lancamentos.dart';
import 'servico_orcamento.dart';

final servicoLancamentosProvider = Provider<ServicoLancamentos>(
  (ref) => ServicoLancamentos(ref.watch(bancoProvider)),
);

final servicoCartaoProvider = Provider<ServicoCartao>(
  (ref) => ServicoCartao(ref.watch(bancoProvider)),
);

final servicoCompromissoProvider = Provider<ServicoCompromisso>(
  (ref) => ServicoCompromisso(ref.watch(bancoProvider)),
);

final servicoImportacaoProvider = Provider<ServicoImportacao>(
  (ref) => ServicoImportacao(ref.watch(bancoProvider)),
);

final servicoBackupProvider = Provider<ServicoBackup>(
  (ref) => ServicoBackup(ref.watch(bancoProvider)),
);

final servicoInvestimentoProvider = Provider<ServicoInvestimento>(
  (ref) => ServicoInvestimento(ref.watch(bancoProvider)),
);

final servicoOrcamentoProvider = Provider<ServicoOrcamento>(
  (ref) => ServicoOrcamento(ref.watch(bancoProvider)),
);
