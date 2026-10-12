class BibleVerse {
  final int id;
  final int libroId;
  final int capitulo;
  final int numero;
  final String texto;
  
  // Metadatos auxiliares de unión (si vienen de join con libro)
  final String? libroNombre;
  final String? libroAbreviatura;

  const BibleVerse({
    required this.id,
    required this.libroId,
    required this.capitulo,
    required this.numero,
    required this.texto,
    this.libroNombre,
    this.libroAbreviatura,
  });

  String get referencia => '${libroAbreviatura ?? libroNombre ?? "Libro $libroId"} $capitulo:$numero';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'libro_id': libroId,
      'capitulo': capitulo,
      'numero': numero,
      'texto': texto,
    };
  }

  factory BibleVerse.fromMap(Map<String, dynamic> map) {
    return BibleVerse(
      id: map['id'] as int,
      libroId: map['libro_id'] as int,
      capitulo: map['capitulo'] as int,
      numero: map['numero'] as int,
      texto: map['texto'] as String,
      libroNombre: map['libro_nombre'] as String?,
      libroAbreviatura: map['libro_abreviatura'] as String?,
    );
  }
}
