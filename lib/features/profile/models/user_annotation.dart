class UserHighlight {
  final int? id;
  final int perfilId;
  final int versiculoId;
  final String color; // '#FFEB3B', '#4CAF50', '#2196F3', '#E91E63', '#9C27B0'
  final DateTime fechaCreacion;
  final String? versiculoTexto;
  final String? referencia;

  const UserHighlight({
    this.id,
    this.perfilId = 1,
    required this.versiculoId,
    required this.color,
    required this.fechaCreacion,
    this.versiculoTexto,
    this.referencia,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'versiculo_id': versiculoId,
      'color': color,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  factory UserHighlight.fromMap(Map<String, dynamic> map, {String? versiculoTexto, String? referencia}) {
    return UserHighlight(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int? ?? 1,
      versiculoId: map['versiculo_id'] as int,
      color: map['color'] as String? ?? '#FFEB3B',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String) ?? DateTime.now()
          : DateTime.now(),
      versiculoTexto: versiculoTexto,
      referencia: referencia,
    );
  }
}

class UserNote {
  final int? id;
  final int perfilId;
  final int versiculoId;
  final String contenido;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final String? versiculoTexto;
  final String? referencia;

  const UserNote({
    this.id,
    this.perfilId = 1,
    required this.versiculoId,
    required this.contenido,
    required this.fechaCreacion,
    required this.fechaModificacion,
    this.versiculoTexto,
    this.referencia,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'versiculo_id': versiculoId,
      'contenido': contenido,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion.toIso8601String(),
    };
  }

  factory UserNote.fromMap(Map<String, dynamic> map, {String? versiculoTexto, String? referencia}) {
    return UserNote(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int? ?? 1,
      versiculoId: map['versiculo_id'] as int,
      contenido: map['contenido'] as String,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String) ?? DateTime.now()
          : DateTime.now(),
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.tryParse(map['fecha_modificacion'] as String) ?? DateTime.now()
          : DateTime.now(),
      versiculoTexto: versiculoTexto,
      referencia: referencia,
    );
  }
}
