class BibleBook {
  final int id;
  final int versionId;
  final String testamento; // 'AT' | 'NT' | 'Deutero'
  final String nombre;
  final String abreviatura;
  final int orden;
  final int totalCapitulos;

  const BibleBook({
    required this.id,
    this.versionId = 1,
    required this.testamento,
    required this.nombre,
    required this.abreviatura,
    required this.orden,
    this.totalCapitulos = 1,
  });

  bool get isAntiguoTestamento => testamento == 'AT';
  bool get isNuevoTestamento => testamento == 'NT';
  bool get isDeuterocanonico => testamento == 'Deutero';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'version_id': versionId,
      'testamento': testamento,
      'nombre': nombre,
      'abreviatura': abreviatura,
      'orden': orden,
    };
  }

  factory BibleBook.fromMap(Map<String, dynamic> map, {int totalCapitulos = 1}) {
    return BibleBook(
      id: map['id'] as int,
      versionId: map['version_id'] as int? ?? 1,
      testamento: map['testamento'] as String,
      nombre: map['nombre'] as String,
      abreviatura: map['abreviatura'] as String,
      orden: map['orden'] as int,
      totalCapitulos: totalCapitulos,
    );
  }
}
