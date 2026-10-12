class Bookmark {
  final int? id;
  final int perfilId;
  final int libroId;
  final int capitulo;
  final int versiculo;
  final String modo; // 'capitulo' | 'versiculo' | 'continuo'
  final DateTime fechaActualizacion;

  // Propiedades añadidas para la UI
  final String? libroNombre;
  final String? libroAbreviatura;

  const Bookmark({
    this.id,
    this.perfilId = 1,
    required this.libroId,
    required this.capitulo,
    required this.versiculo,
    this.modo = 'continuo',
    required this.fechaActualizacion,
    this.libroNombre,
    this.libroAbreviatura,
  });

  String get referencia => '${libroAbreviatura ?? libroNombre ?? "Libro $libroId"} $capitulo:$versiculo';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'libro_id': libroId,
      'capitulo': capitulo,
      'versiculo': versiculo,
      'modo': modo,
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map, {String? libroNombre, String? libroAbreviatura}) {
    return Bookmark(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int? ?? 1,
      libroId: map['libro_id'] as int,
      capitulo: map['capitulo'] as int,
      versiculo: map['versiculo'] as int,
      modo: map['modo'] as String? ?? 'continuo',
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.tryParse(map['fecha_actualizacion'] as String) ?? DateTime.now()
          : DateTime.now(),
      libroNombre: libroNombre,
      libroAbreviatura: libroAbreviatura,
    );
  }
}
