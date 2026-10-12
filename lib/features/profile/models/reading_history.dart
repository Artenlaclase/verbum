class ReadingHistory {
  final int? id;
  final int perfilId;
  final int libroId;
  final int capitulo;
  final int? versiculoInicio;
  final int? versiculoFin;
  final DateTime fecha;
  final String? libroNombre;

  const ReadingHistory({
    this.id,
    this.perfilId = 1,
    required this.libroId,
    required this.capitulo,
    this.versiculoInicio,
    this.versiculoFin,
    required this.fecha,
    this.libroNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'libro_id': libroId,
      'capitulo': capitulo,
      'versiculo_inicio': versiculoInicio,
      'versiculo_fin': versiculoFin,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory ReadingHistory.fromMap(Map<String, dynamic> map, {String? libroNombre}) {
    return ReadingHistory(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int? ?? 1,
      libroId: map['libro_id'] as int,
      capitulo: map['capitulo'] as int,
      versiculoInicio: map['versiculo_inicio'] as int?,
      versiculoFin: map['versiculo_fin'] as int?,
      fecha: map['fecha'] != null
          ? DateTime.tryParse(map['fecha'] as String) ?? DateTime.now()
          : DateTime.now(),
      libroNombre: libroNombre,
    );
  }
}
