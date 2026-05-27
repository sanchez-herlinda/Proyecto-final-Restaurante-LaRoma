import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.backgroundBeige,
      primaryColor: AppColors.primaryBrown,

      // Configuración de la tipografía basada en Playfair / Serif para el estilo italiano
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
            color: AppColors.textDark, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(
            color: AppColors
                .textDark), // Para textos de lectura (ej. descripciones)
      ),

      // Estilo global de los botones (Botones Café)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          foregroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero), // Bordes cuadrados según Figma
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),

      // AppBar Global (Fondo blanco, texto oscuro, sin sombra)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
