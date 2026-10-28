import 'enums.dart';

/// Configurações do app (tabela `configuracoes`, chave/valor) já interpretadas.
class AjustesApp {
  const AjustesApp({
    this.tema = 'dark',
    this.modoParcelados = ModoParcelados.rigido,
    this.descontarFixos = true,
    this.comportamentoEstouro = ComportamentoEstouro.confirmar,
    this.ocultarValores = false,
    this.bloqueioMinutos = 2,
    this.biometria = false,
    this.ultimoBackup,
  });

  factory AjustesApp.deMapa(Map<String, String> m) => AjustesApp(
        tema: m['tema'] ?? 'dark',
        modoParcelados: ModoParcelados.values.asNameMap()[m['modo_parcelados']] ??
            ModoParcelados.rigido,
        descontarFixos: (m['descontar_fixos'] ?? 'true') == 'true',
        comportamentoEstouro:
            ComportamentoEstouro.values.asNameMap()[m['comportamento_estouro']] ??
                ComportamentoEstouro.confirmar,
        ocultarValores: (m['ocultar_valores'] ?? 'false') == 'true',
        bloqueioMinutos: int.tryParse(m['bloqueio_minutos'] ?? '') ?? 2,
        biometria: (m['biometria'] ?? 'false') == 'true',
        ultimoBackup: DateTime.tryParse(m['ultimo_backup'] ?? ''),
      );

  /// `dark`, `light` ou `system`.
  final String tema;
  final ModoParcelados modoParcelados;
  final bool descontarFixos;
  final ComportamentoEstouro comportamentoEstouro;
  final bool ocultarValores;

  /// Minutos em segundo plano antes de pedir a senha de novo (0 = sempre).
  final int bloqueioMinutos;
  final bool biometria;
  final DateTime? ultimoBackup;

  @override
  bool operator ==(Object other) =>
      other is AjustesApp &&
      other.tema == tema &&
      other.modoParcelados == modoParcelados &&
      other.descontarFixos == descontarFixos &&
      other.comportamentoEstouro == comportamentoEstouro &&
      other.ocultarValores == ocultarValores &&
      other.bloqueioMinutos == bloqueioMinutos &&
      other.biometria == biometria &&
      other.ultimoBackup == ultimoBackup;

  @override
  int get hashCode => Object.hash(tema, modoParcelados, descontarFixos,
      comportamentoEstouro, ocultarValores, bloqueioMinutos, biometria, ultimoBackup);
}
