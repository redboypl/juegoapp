// ============================================================
// app_colors.dart — Paleta de colores centralizada de la app
// Cualquier color usado en más de un lugar debería vivir aquí.
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Fondo degradado oscuro ---
  static const Color fondoOscuro = Color(0xFF1A1A2E);
  static const Color surfaceTop = Color(0xFF16213E);
  static const Color fondoProfundo = Color(0xFF0F3460);

  static const LinearGradient fondoDegradado = LinearGradient(
    colors: [fondoOscuro, surfaceTop, fondoProfundo],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Acentos ---
  static const Color rojoVenezolano = Color(0xFFE63946);
  static const Color azulAcento = Color(0xFF185FA5);
  static const Color acentoDorado = Color(0xFFFFC107);

  // --- Dificultad: Fácil ---
  static const Color facilTexto = Color(0xFF3B6D11);
  static const Color facilFondo = Color(0xFFEAF3DE);

  // --- Dificultad: Media ---
  static const Color mediaTexto = Color(0xFF854F0B);
  static const Color mediaFondo = Color(0xFFFAEEDA);

  // --- Dificultad: Difícil ---
  static const Color dificilTexto = Color(0xFFA32D2D);
  static const Color dificilFondo = Color(0xFFFCEBEB);
}
