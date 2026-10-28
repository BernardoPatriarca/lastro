import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'servico_cartao.dart';
import 'servico_lancamentos.dart';

final servicoLancamentosProvider = Provider<ServicoLancamentos>(
  (ref) => ServicoLancamentos(ref.watch(bancoProvider)),
);

final servicoCartaoProvider = Provider<ServicoCartao>(
  (ref) => ServicoCartao(ref.watch(bancoProvider)),
);
