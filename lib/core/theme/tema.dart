import 'package:flutter/material.dart';

import 'cores_lastro.dart';

/// Temas Material 3 do Lastro. Fonte Inter (embutida em assets/fonts).
abstract final class TemaLastro {
  static const _fonte = 'Inter';

  static final ColorScheme _esquemaClaro = ColorScheme.fromSeed(
    seedColor: PaletaLastro.primaria,
    brightness: Brightness.light,
  ).copyWith(
    primary: PaletaLastro.primaria,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFCCFBF1),
    onPrimaryContainer: PaletaLastro.primariaEscura,
    secondary: PaletaLastro.secundariaClaro,
    onSecondary: PaletaLastro.fundoEscuro,
    secondaryContainer: const Color(0xFFD5F5F0),
    onSecondaryContainer: PaletaLastro.primariaEscura,
    error: PaletaLastro.negativo,
    onError: Colors.white,
    surface: PaletaLastro.fundoClaro,
    onSurface: PaletaLastro.fundoEscuro,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Colors.white,
    surfaceContainer: const Color(0xFFEDF2F2),
    surfaceContainerHigh: const Color(0xFFE6ECEC),
  );

  static final ColorScheme _esquemaEscuro = ColorScheme.fromSeed(
    seedColor: PaletaLastro.primaria,
    brightness: Brightness.dark,
  ).copyWith(
    primary: PaletaLastro.primaria,
    onPrimary: Colors.white,
    primaryContainer: PaletaLastro.primariaEscura,
    onPrimaryContainer: const Color(0xFFCCFBF1),
    secondary: PaletaLastro.secundariaEscuro,
    onSecondary: PaletaLastro.fundoEscuro,
    secondaryContainer: const Color(0xFF134E4A),
    onSecondaryContainer: PaletaLastro.secundariaEscuro,
    error: const Color(0xFFF87171),
    onError: PaletaLastro.fundoEscuro,
    surface: PaletaLastro.fundoEscuro,
    onSurface: const Color(0xFFE6EEEE),
    surfaceContainerLowest: const Color(0xFF080D10),
    surfaceContainerLow: const Color(0xFF111A1E),
    surfaceContainer: const Color(0xFF151F24),
    surfaceContainerHigh: const Color(0xFF1B272D),
  );

  static ThemeData get claro => _montar(_esquemaClaro, CoresLastro.claro);
  static ThemeData get escuro => _montar(_esquemaEscuro, CoresLastro.escuro);

  static ThemeData _montar(ColorScheme esquema, CoresLastro cores) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fonte,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      extensions: [cores],
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fonte,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: esquema.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: esquema.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: esquema.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: esquema.surfaceContainer,
        indicatorColor: esquema.primaryContainer,
        height: 68,
        // Cinco abas cabem em celulares estreitos sem quebrar "Investimentos".
        labelPadding: EdgeInsets.zero,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: _fonte,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: esquema.onSurface,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: _fonte,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
    );
  }
}
