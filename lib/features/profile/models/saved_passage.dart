class SavedPassage {
  final int? id;
  final int perfilId;
  final String? titulo;
  final String referenciaInicio;
  final String? referenciaFin;
  final int libroId;
  final int capituloInicio;
  final int versiculoInicio;
  final int? capituloFin;
  final int? versiculoFin;
  final String textoSnapshot;
  final String etiqueta; // Fe, Oración, Consuelo, Esperanza, Gratitud, Amor, etc.
  final String color; // Hex string e.g. '#6A2C8F', '#2E7D32', etc.
  final DateTime fechaGuardado;
  final String? notas;

  const SavedPassage({
    this.id,
    this.perfilId = 1,
    this.titulo,
    required this.referenciaInicio,
    this.referenciaFin,
    required this.libroId,
    required this.capituloInicio,
    required this.versiculoInicio,
    this.capituloFin,
    this.versiculoFin,
    required this.textoSnapshot,
    this.etiqueta = 'Fe',
    this.color = '#C9A227',
    required this.fechaGuardado,
    this.notas,
  });

  String get referenciaCompleta {
    if (referenciaFin != null && referenciaFin!.isNotEmpty && referenciaFin != referenciaInicio) {
      return '$referenciaInicio - $referenciaFin';
    }
    return referenciaInicio;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'titulo': titulo,
      'referencia_inicio': referenciaInicio,
      'referencia_fin': referenciaFin,
      'libro_id': libroId,
      'capitulo_inicio': capituloInicio,
      'versiculo_inicio': versiculoInicio,
      'capitulo_fin': capituloFin,
      'versiculo_fin': versiculoFin,
      'texto_snapshot': textoSnapshot,
      'etiqueta': etiqueta,
      'color': color,
      'fecha_guardado': fechaGuardado.toIso8601String(),
    };
  }

  factory SavedPassage.fromMap(Map<String, dynamic> map) {
    return SavedPassage(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int? ?? 1,
      titulo: map['titulo'] as String?,
      referenciaInicio: map['referencia_inicio'] as String,
      referenciaFin: map['referencia_fin'] as String?,
      libroId: map['libro_id'] as int,
      capituloInicio: map['capitulo_inicio'] as int,
      versiculoInicio: map['versiculo_inicio'] as int,
      capituloFin: map['capitulo_fin'] as int?,
      versiculoFin: map['versiculo_fin'] as int?,
      textoSnapshot: map['texto_snapshot'] as String,
      etiqueta: map['etiqueta'] as String? ?? 'Fe',
      color: map['color'] as String? ?? '#C9A227',
      fechaGuardado: map['fecha_guardado'] != null
          ? DateTime.tryParse(map['fecha_guardado'] as String) ?? DateTime.now()
          : DateTime.now(),
      notas: map['notas'] as String?,
    );
  }
}
