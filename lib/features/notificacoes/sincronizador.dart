import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/derivados.dart';
import '../../data/notificacoes/agendador.dart';
import '../../data/providers.dart';

/// Agendador real do sistema. Os testes sobrescrevem por um falso.
final agendadorProvider = Provider<AgendadorNotificacoes>((ref) => AgendadorPlugin());

/// Mantém os avisos agendados em dia: sempre que faturas, contas fixas ou as
/// configurações mudam, reagenda (com uma pequena espera para juntar mudanças).
/// Quem observa este provider (a casca do app) o mantém ativo.
final sincronizadorNotificacoesProvider = Provider<void>((ref) {
  final agendador = ref.watch(agendadorProvider);
  Timer? espera;
  String? ultimo;
  ref.onDispose(() => espera?.cancel());

  Future<void> sincronizar() async {
    // Enquanto os dados carregam, a lista viria vazia e apagaria os avisos.
    final carregado = ref.read(faturasProvider).hasValue &&
        ref.read(ocorrenciasProvider).hasValue &&
        ref.read(compromissosProvider).hasValue;
    if (!carregado) return;

    final ligado = ref.read(ajustesProvider).notificacoes;
    final planejadas = ref.read(notificacoesPlanejadasProvider);
    final assinatura = ligado
        ? planejadas.map((n) => '${n.id}@${n.quando.millisecondsSinceEpoch}').join(',')
        : 'desligado';
    if (assinatura == ultimo) return; // nada mudou
    ultimo = assinatura;

    if (!ligado) {
      await agendador.cancelarTodas();
      return;
    }
    // Sem permissão (negada depois), não adianta agendar.
    if (!await agendador.permitido()) return;
    await agendador.substituir(planejadas);
  }

  void agendarSincronizacao() {
    espera?.cancel();
    espera = Timer(const Duration(milliseconds: 600), () => unawaited(sincronizar()));
  }

  ref.listen(notificacoesPlanejadasProvider, (_, _) => agendarSincronizacao());
  ref.listen(ajustesProvider.select((a) => a.notificacoes), (_, _) => agendarSincronizacao());
  agendarSincronizacao();
});
