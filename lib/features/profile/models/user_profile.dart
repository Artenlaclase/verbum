import 'dart:convert';

class UserProfile {
  final int id;
  final String nombre;
  final String avatar; // Emoji o identificador de avatar local
  final DateTime fechaCreacion;
  final Map<String, dynamic> preferencias;

  const UserProfile({
    required this.id,
    required this.nombre,
    required this.avatar,
    required this.fechaCreacion,
    this.preferencias = const {},
  });

  double get fontSize => (preferencias['fontSize'] as num?)?.toDouble() ?? 18.0;
  String get themeMode => preferencias['themeMode'] as String? ?? 'system';
  String get readerFont => preferencias['readerFont'] as String? ?? 'Merriweather';

  UserProfile copyWith({
    int? id,
    String? nombre,
    String? avatar,
    DateTime? fechaCreacion,
    Map<String, dynamic>? preferencias,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      avatar: avatar ?? this.avatar,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      preferencias: preferencias ?? this.preferencias,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'avatar': avatar,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'preferencias': jsonEncode(preferencias),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> prefs = {};
    if (map['preferencias'] != null && map['preferencias'] is String) {
      try {
        prefs = jsonDecode(map['preferencias'] as String) as Map<String, dynamic>;
      } catch (_) {}
    } else if (map['preferencias'] is Map) {
      prefs = Map<String, dynamic>.from(map['preferencias'] as Map);
    }

    return UserProfile(
      id: map['id'] as int? ?? 1,
      nombre: map['nombre'] as String? ?? 'Lector Verbum',
      avatar: map['avatar'] as String? ?? '✝️',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String) ?? DateTime.now()
          : DateTime.now(),
      preferencias: prefs,
    );
  }
}
