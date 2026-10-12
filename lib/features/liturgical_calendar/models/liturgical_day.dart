import 'package:flutter/material.dart';
import '../../../core/theme/liturgical_colors.dart';
import 'daily_reading.dart';


class LiturgicalDay {
  final DateTime fecha;
  final String tiempo; // Adviento, Navidad, Cuaresma, Pascua, Tiempo Ordinario
  final String celebracion; // Ej: Domingo II de Pascua, Santa María Madre de Dios
  final String rango; // solemnidad, fiesta, memoria, feria
  final String colorNombre; // morado, blanco, rojo, verde, rosa, dorado
  final String cicloDominical; // A, B, C
  final String cicloFerial; // I, II
  final int semanaTiempo; // Semana 1, 2, 3...
  final List<DailyReading> lecturas;

  const LiturgicalDay({
    required this.fecha,
    required this.tiempo,
    required this.celebracion,
    required this.rango,
    required this.colorNombre,
    required this.cicloDominical,
    required this.cicloFerial,
    this.semanaTiempo = 1,
    this.lecturas = const [],
  });

  Color get color => LiturgicalColors.fromName(colorNombre);

  bool get isSolemnidad => rango.toLowerCase() == 'solemnidad';
  bool get isFiesta => rango.toLowerCase() == 'fiesta';
  bool get isMemoria => rango.toLowerCase() == 'memoria';
  bool get isFeria => rango.toLowerCase() == 'feria';

  LiturgicalDay copyWith({
    DateTime? fecha,
    String? tiempo,
    String? celebracion,
    String? rango,
    String? colorNombre,
    String? cicloDominical,
    String? cicloFerial,
    int? semanaTiempo,
    List<DailyReading>? lecturas,
  }) {
    return LiturgicalDay(
      fecha: fecha ?? this.fecha,
      tiempo: tiempo ?? this.tiempo,
      celebracion: celebracion ?? this.celebracion,
      rango: rango ?? this.rango,
      colorNombre: colorNombre ?? this.colorNombre,
      cicloDominical: cicloDominical ?? this.cicloDominical,
      cicloFerial: cicloFerial ?? this.cicloFerial,
      semanaTiempo: semanaTiempo ?? this.semanaTiempo,
      lecturas: lecturas ?? this.lecturas,
    );
  }
}
