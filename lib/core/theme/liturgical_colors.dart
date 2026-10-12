import 'package:flutter/material.dart';

/// Paleta litúrgica oficial de Verbum v1.1
/// Colores según la ordenación general del Misal Romano y el informe técnico MVP.
class LiturgicalColors {
  LiturgicalColors._();

  // Colores principales según especificación
  static const Color morado = Color(0xFF6A2C8F); // Adviento, Cuaresma, Penitencial
  static const Color blanco = Color(0xFFF5F1E8); // Navidad, Pascua, Solemnidades
  static const Color blancoText = Color(0xFF1E293B); // Texto para fondos blancos
  static const Color rojo = Color(0xFFB22234);   // Pentecostés, Mártires, Viernes Santo
  static const Color verde = Color(0xFF2E7D32);  // Tiempo Ordinario
  static const Color rosa = Color(0xFFE8A0BF);   // Gaudete, Laetare
  static const Color dorado = Color(0xFFC9A227); // Solemnidades especiales y Navidad

  // Colores secundarios y acentos litúrgicos
  static const Color moradoOscuro = Color(0xFF431660);
  static const Color verdeOscuro = Color(0xFF1B4D20);
  static const Color rojoOscuro = Color(0xFF7A1320);
  static const Color doradoClaro = Color(0xFFF4D06F);

  /// Retorna el color principal a partir del nombre del color litúrgico
  static Color fromName(String? name) {
    if (name == null) return verde;
    switch (name.toLowerCase().trim()) {
      case 'morado':
      case 'violeta':
      case 'purple':
        return morado;
      case 'blanco':
      case 'white':
        return blanco;
      case 'rojo':
      case 'red':
        return rojo;
      case 'verde':
      case 'green':
        return verde;
      case 'rosa':
      case 'rose':
      case 'pink':
        return rosa;
      case 'dorado':
      case 'gold':
        return dorado;
      default:
        return verde;
    }
  }

  /// Retorna un color de texto con alto contraste para el color litúrgico dado
  static Color getContrastText(Color background) {
    if (background == blanco || background.computeLuminance() > 0.55) {
      return const Color(0xFF1A1A1A);
    }
    return Colors.white;
  }

  /// Gradiente litúrgico sutil para tarjetas y encabezados
  static LinearGradient getGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        HSLColor.fromColor(baseColor)
            .withLightness((HSLColor.fromColor(baseColor).lightness - 0.08).clamp(0.0, 1.0))
            .toColor(),
      ],
    );
  }
}
