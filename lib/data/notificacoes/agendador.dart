import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/notificacoes.dart';

/// Agenda avisos no sistema. Isolado em uma interface para os testes.
abstract interface class AgendadorNotificacoes {
  /// Pede a permissão de notificações (Android 13+). `true` se concedida.
  Future<bool> pedirPermissao();

  /// `true` se o app já pode notificar.
  Future<bool> permitido();

  /// Cancela tudo que estava agendado e agenda [notificacoes].
  Future<void> substituir(List<NotificacaoPlanejada> notificacoes);

  /// Cancela todos os avisos agendados.
  Future<void> cancelarTodas();
}

/// Implementação real com `flutter_local_notifications`.
///
/// Usa horários absolutos (instante em UTC): não depende do fuso do aparelho
/// nem de banco de fusos. Alarmes **inexatos** (sem permissão de alarme exato):
/// o Android pode atrasar o aviso alguns minutos, o que basta para vencimentos.
class AgendadorPlugin implements AgendadorNotificacoes {
  AgendadorPlugin([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _iniciado = false;

  static const _canal = AndroidNotificationDetails(
    'vencimentos',
    'Vencimentos',
    channelDescription: 'Avisos de faturas e contas a vencer',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_notificacao',
  );

  Future<void> _iniciar() async {
    if (_iniciado) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notificacao'),
      ),
    );
    _iniciado = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> pedirPermissao() async {
    await _iniciar();
    return await _android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<bool> permitido() async {
    await _iniciar();
    return await _android?.areNotificationsEnabled() ?? false;
  }

  @override
  Future<void> substituir(List<NotificacaoPlanejada> notificacoes) async {
    await _iniciar();
    await _plugin.cancelAll();
    for (final n in notificacoes) {
      await _plugin.zonedSchedule(
        id: n.id,
        title: n.titulo,
        body: n.corpo,
        scheduledDate: tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.UTC,
          n.quando.millisecondsSinceEpoch,
        ),
        notificationDetails: const NotificationDetails(android: _canal),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelarTodas() async {
    await _iniciar();
    await _plugin.cancelAll();
  }
}

/// Falso para testes: guarda o que foi agendado.
class AgendadorFalso implements AgendadorNotificacoes {
  AgendadorFalso({this.concede = true});

  final bool concede;
  bool _permitido = false;
  List<NotificacaoPlanejada> agendadas = const [];
  int vezesAgendado = 0;

  @override
  Future<bool> pedirPermissao() async {
    _permitido = concede;
    return concede;
  }

  @override
  Future<bool> permitido() async => _permitido;

  @override
  Future<void> substituir(List<NotificacaoPlanejada> notificacoes) async {
    agendadas = notificacoes;
    vezesAgendado++;
  }

  @override
  Future<void> cancelarTodas() async => agendadas = const [];
}
