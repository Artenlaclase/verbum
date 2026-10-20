import 'package:flutter/material.dart';

enum ThematicCategoryType {
  amor,
  dinero,
  salud,
  amistad,
  armonia;

  String get id => name;

  String get title {
    switch (this) {
      case ThematicCategoryType.amor:
        return 'Amor';
      case ThematicCategoryType.dinero:
        return 'Dinero y Trabajo';
      case ThematicCategoryType.salud:
        return 'Salud y Sanidad';
      case ThematicCategoryType.amistad:
        return 'Amistad';
      case ThematicCategoryType.armonia:
        return 'Armonía y Paz';
    }
  }

  String get emoji {
    switch (this) {
      case ThematicCategoryType.amor:
        return '❤️';
      case ThematicCategoryType.dinero:
        return '💼';
      case ThematicCategoryType.salud:
        return '🌿';
      case ThematicCategoryType.amistad:
        return '🤝';
      case ThematicCategoryType.armonia:
        return '🕊️';
    }
  }

  String get subtitle {
    switch (this) {
      case ThematicCategoryType.amor:
        return 'Caridad, entrega y compasión';
      case ThematicCategoryType.dinero:
        return 'Mayordomía, providencia y rectitud';
      case ThematicCategoryType.salud:
        return 'Sanidad física, mental y fortaleza';
      case ThematicCategoryType.amistad:
        return 'Lealtad, fraternidad y comunión';
      case ThematicCategoryType.armonia:
        return 'Paz interior, serenidad y sosiego';
    }
  }

  IconData get icon {
    switch (this) {
      case ThematicCategoryType.amor:
        return Icons.favorite_rounded;
      case ThematicCategoryType.dinero:
        return Icons.savings_rounded;
      case ThematicCategoryType.salud:
        return Icons.healing_rounded;
      case ThematicCategoryType.amistad:
        return Icons.groups_rounded;
      case ThematicCategoryType.armonia:
        return Icons.spa_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ThematicCategoryType.amor:
        return const Color(0xFFD32F2F); // Rojo cálido / Amor
      case ThematicCategoryType.dinero:
        return const Color(0xFF2E7D32); // Verde esmeralda / Prosperidad
      case ThematicCategoryType.salud:
        return const Color(0xFF0288D1); // Azul sereno / Sanidad
      case ThematicCategoryType.amistad:
        return const Color(0xFFE65100); // Ámbar naranja / Amistad
      case ThematicCategoryType.armonia:
        return const Color(0xFF6A1B9A); // Púrpura espiritual / Armonía
    }
  }
}

class ThematicReadingSuggestion {
  final ThematicCategoryType category;
  final String referencia;
  final String lema;
  final String reflexion;
  final String contexto;

  const ThematicReadingSuggestion({
    required this.category,
    required this.referencia,
    required this.lema,
    required this.reflexion,
    required this.contexto,
  });
}
