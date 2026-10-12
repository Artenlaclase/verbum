class DailyReading {
  final int? id;
  final String fecha; // 'YYYY-MM-DD'
  final String ciclo; // 'A' | 'B' | 'C'
  final int? anioPar; // 1 o 2
  final String tipo; // 'primera' | 'salmo' | 'segunda' | 'evangelio'
  final String referencia; // SOLO referencia, ej: 'Jn 3:16-21'
  final String? pasajeTitulo;

  const DailyReading({
    this.id,
    required this.fecha,
    required this.ciclo,
    this.anioPar,
    required this.tipo,
    required this.referencia,
    this.pasajeTitulo,
  });

  String get tipoTitulo {
    switch (tipo.toLowerCase()) {
      case 'primera':
        return '1ª Lectura';
      case 'salmo':
        return 'Salmo Responsorial';
      case 'segunda':
        return '2ª Lectura';
      case 'evangelio':
        return 'Evangelio';
      default:
        return tipo;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'ciclo': ciclo,
      'anio_par': anioPar,
      'tipo': tipo,
      'referencia': referencia,
    };
  }

  factory DailyReading.fromMap(Map<String, dynamic> map) {
    return DailyReading(
      id: map['id'] as int?,
      fecha: map['fecha'] as String,
      ciclo: map['ciclo'] as String,
      anioPar: map['anio_par'] as int?,
      tipo: map['tipo'] as String,
      referencia: map['referencia'] as String,
    );
  }
}
