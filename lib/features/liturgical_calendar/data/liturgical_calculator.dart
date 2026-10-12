import '../models/daily_reading.dart';
import '../models/liturgical_day.dart';

/// Motor de cálculo del Calendario Litúrgico Católico Romano
/// Implementa el algoritmo de Meeus/Jones/Butcher para el Computus pascual
/// y las reglas canónicas de tiempos, colores y ciclos A/B/C y I/II.
class LiturgicalCalculator {
  LiturgicalCalculator._();

  /// Calcula la fecha del Domingo de Pascua para un año gregoriano
  /// Algoritmo astronómico/eclesiástico Meeus/Jones/Butcher
  static DateTime getEasterSunday(int year) {
    final int a = year % 19;
    final int b = year ~/ 100;
    final int c = year % 100;
    final int d = b ~/ 4;
    final int e = b % 4;
    final int f = (b + 8) ~/ 25;
    final int g = (b - f + 1) ~/ 3;
    final int h = (19 * a + b - d - g + 15) % 30;
    final int i = c ~/ 4;
    final int k = c % 4;
    final int l = (32 + 2 * e + 2 * i - h - k) % 7;
    final int m = (a + 11 * h + 22 * l) ~/ 451;
    final int month = (h + l - 7 * m + 114) ~/ 31;
    final int day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime.utc(year, month, day);
  }

  /// Calcula el primer domingo de Adviento para un año
  static DateTime getFirstSundayOfAdvent(int year) {
    final christmas = DateTime.utc(year, 12, 25);
    // Retroceder 4 domingos antes de Navidad
    int daysToSunday = christmas.weekday % 7;
    if (daysToSunday == 0) daysToSunday = 7;
    final fourthSunday = christmas.subtract(Duration(days: daysToSunday));
    return fourthSunday.subtract(const Duration(days: 21));
  }

  /// Ciclo dominical (A, B, C)
  /// El año litúrgico inicia en Adviento del año anterior
  static String getSundayCycle(DateTime date) {
    final advent = getFirstSundayOfAdvent(date.year);
    int liturgicalYear = date.year;
    if (date.isAfter(advent) || date.isAtSameMomentAs(advent)) {
      liturgicalYear = date.year + 1;
    }
    final remainder = liturgicalYear % 3;
    if (remainder == 1) return 'A';
    if (remainder == 2) return 'B';
    return 'C';
  }

  /// Ciclo ferial (I impar, II par)
  static String getWeekdayCycle(DateTime date) {
    final advent = getFirstSundayOfAdvent(date.year);
    int liturgicalYear = date.year;
    if (date.isAfter(advent) || date.isAtSameMomentAs(advent)) {
      liturgicalYear = date.year + 1;
    }
    return (liturgicalYear % 2 == 0) ? 'II' : 'I';
  }

  /// Calcula el estado litúrgico completo para cualquier fecha
  static LiturgicalDay getLiturgicalDay(DateTime inputDate) {
    final date = DateTime.utc(inputDate.year, inputDate.month, inputDate.day);
    final year = date.year;
    final easter = getEasterSunday(year);
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final palmSunday = easter.subtract(const Duration(days: 7));
    final pentecost = easter.add(const Duration(days: 49));
    final advent = getFirstSundayOfAdvent(year);
    final christmas = DateTime.utc(year, 12, 25);

    final epiphany = DateTime.utc(year, 1, 6);
    // Bautismo del Señor: domingo después de Epifanía
    final baptismDays = (7 - epiphany.weekday) % 7;
    final baptism = epiphany.add(Duration(days: baptismDays == 0 ? 7 : baptismDays));

    final cicloDom = getSundayCycle(date);
    final cicloFer = getWeekdayCycle(date);

    // Solemnidades fijas universales
    if (date.month == 1 && date.day == 1) {
      return LiturgicalDay(
        fecha: date,
        tiempo: 'Navidad',
        celebracion: 'Santa María, Madre de Dios',
        rango: 'solemnidad',
        colorNombre: 'blanco',
        cicloDominical: cicloDom,
        cicloFerial: cicloFer,
        lecturas: [
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Núm 6:22-27'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 67:2-3, 5, 6, 8'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: 'Gál 4:4-7'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Lc 2:16-21'),
        ],
      );
    }

    if (date.month == 12 && date.day == 25) {
      return LiturgicalDay(
        fecha: date,
        tiempo: 'Navidad',
        celebracion: 'La Natividad del Señor (Navidad)',
        rango: 'solemnidad',
        colorNombre: 'blanco',
        cicloDominical: cicloDom,
        cicloFerial: cicloFer,
        lecturas: [
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Isa 52:7-10'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 98:1-6'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: 'Heb 1:1-6'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Jn 1:1-18'),
        ],
      );
    }

    // 1. TIEMPO DE ADVIENTO
    if (date.isAfter(advent.subtract(const Duration(days: 1))) && date.isBefore(christmas)) {
      final daysSinceAdvent = date.difference(advent).inDays;
      final weekOfAdvent = (daysSinceAdvent ~/ 7) + 1;
      final isSunday = date.weekday == DateTime.sunday;
      // 3er domingo de Adviento = Domingo de Gaudete (Rosa)
      final isGaudete = isSunday && weekOfAdvent == 3;

      return LiturgicalDay(
        fecha: date,
        tiempo: 'Adviento',
        celebracion: isSunday
            ? (isGaudete ? 'III Domingo de Adviento (Gaudete)' : 'Domingo $weekOfAdvent de Adviento')
            : 'Feria de Adviento, Semana $weekOfAdvent',
        rango: isSunday ? 'solemnidad' : 'feria',
        colorNombre: isGaudete ? 'rosa' : 'morado',
        cicloDominical: cicloDom,
        cicloFerial: cicloFer,
        semanaTiempo: weekOfAdvent,
        lecturas: _getAdventReadings(date, cicloDom),
      );
    }

    // 2. TIEMPO DE NAVIDAD
    if ((date.month == 12 && date.day >= 25) || date.isBefore(baptism.add(const Duration(days: 1)))) {
      return LiturgicalDay(
        fecha: date,
        tiempo: 'Navidad',
        celebracion: date.month == 1 && date.day == 6
            ? 'La Epifanía del Señor'
            : (date.isAtSameMomentAs(baptism) ? 'El Bautismo del Señor' : 'Tiempo de Navidad'),
        rango: (date.month == 1 && date.day == 6) || date.isAtSameMomentAs(baptism) ? 'solemnidad' : 'feria',
        colorNombre: 'blanco',
        cicloDominical: cicloDom,
        cicloFerial: cicloFer,
        lecturas: _getChristmasReadings(date, cicloDom),
      );
    }

    // 3. TIEMPO DE CUARESMA Y SEMANA SANTA
    if (date.isAfter(ashWednesday.subtract(const Duration(days: 1))) && date.isBefore(easter)) {
      if (date.isAtSameMomentAs(ashWednesday)) {
        return LiturgicalDay(
          fecha: date,
          tiempo: 'Cuaresma',
          celebracion: 'Miércoles de Ceniza',
          rango: 'solemnidad',
          colorNombre: 'morado',
          cicloDominical: cicloDom,
          cicloFerial: cicloFer,
          lecturas: [
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Joel 2:12-18'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 51:3-6, 12-14, 17'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: '2 Cor 5:20-6:2'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Mt 6:1-6, 16-18'),
          ],
        );
      }

      if (date.isAtSameMomentAs(palmSunday)) {
        return LiturgicalDay(
          fecha: date,
          tiempo: 'Semana Santa',
          celebracion: 'Domingo de Ramos en la Pasión del Señor',
          rango: 'solemnidad',
          colorNombre: 'rojo',
          cicloDominical: cicloDom,
          cicloFerial: cicloFer,
          lecturas: [
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Isa 50:4-7'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 22:8-9, 17-20, 23-24'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: 'Fil 2:6-11'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Mc 14:1-15:47'),
          ],
        );
      }

      final daysToEaster = easter.difference(date).inDays;
      if (daysToEaster == 2) {
        return LiturgicalDay(
          fecha: date,
          tiempo: 'Triduo Pascual',
          celebracion: 'Viernes Santo de la Pasión del Señor',
          rango: 'solemnidad',
          colorNombre: 'rojo',
          cicloDominical: cicloDom,
          cicloFerial: cicloFer,
          lecturas: [
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Isa 52:13-53:12'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 31:2, 6, 12-17, 25'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: 'Heb 4:14-16; 5:7-9'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Jn 18:1-19:42'),
          ],
        );
      }

      final daysSinceAsh = date.difference(ashWednesday).inDays;
      final weekOfLent = (daysSinceAsh ~/ 7) + 1;
      final isSunday = date.weekday == DateTime.sunday;
      final isLaetare = isSunday && weekOfLent == 4;

      return LiturgicalDay(
        fecha: date,
        tiempo: 'Cuaresma',
        celebracion: isSunday
            ? (isLaetare ? 'IV Domingo de Cuaresma (Laetare)' : 'Domingo $weekOfLent de Cuaresma')
            : 'Feria de Cuaresma, Semana $weekOfLent',
        rango: isSunday ? 'solemnidad' : 'feria',
        colorNombre: isLaetare ? 'rosa' : 'morado',
        cicloDominical: cicloDom,
        cicloFerial: cicloFer,
        semanaTiempo: weekOfLent,
        lecturas: _getLentReadings(date, cicloDom),
      );
    }

    // 4. TIEMPO DE PASCUA
    if (date.isAfter(easter.subtract(const Duration(days: 1))) && date.isBefore(pentecost.add(const Duration(days: 1)))) {
      if (date.isAtSameMomentAs(easter)) {
        return LiturgicalDay(
          fecha: date,
          tiempo: 'Pascua',
          celebracion: 'Domingo de Resurrección del Señor',
          rango: 'solemnidad',
          colorNombre: 'blanco',
          cicloDominical: cicloDom,
          cicloFerial: cicloFer,
          lecturas: [
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Hch 10:34a, 37-43'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 118:1-2, 16-17, 22-23'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: 'Col 3:1-4'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Jn 20:1-9'),
          ],
        );
      }

      if (date.isAtSameMomentAs(pentecost)) {
        return LiturgicalDay(
          fecha: date,
          tiempo: 'Pascua',
          celebracion: 'Domingo de Pentecostés',
          rango: 'solemnidad',
          colorNombre: 'rojo',
          cicloDominical: cicloDom,
          cicloFerial: cicloFer,
          lecturas: [
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Hch 2:1-11'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 104:1, 24, 29-31, 34'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: '1 Cor 12:3b-7, 12-13'),
            DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Jn 20:19-23'),
          ],
        );
      }

      final daysSinceEaster = date.difference(easter).inDays;
      final weekOfEaster = (daysSinceEaster ~/ 7) + 1;
      final isSunday = date.weekday == DateTime.sunday;

      return LiturgicalDay(
        fecha: date,
        tiempo: 'Pascua',
        celebracion: isSunday ? 'Domingo $weekOfEaster de Pascua' : 'Feria de Pascua, Semana $weekOfEaster',
        rango: isSunday ? 'solemnidad' : 'feria',
        colorNombre: 'blanco',
        cicloDominical: cicloDom,
        cicloFerial: cicloFer,
        semanaTiempo: weekOfEaster,
        lecturas: _getEasterReadings(date, cicloDom),
      );
    }

    // 5. TIEMPO ORDINARIO
    final isSunday = date.weekday == DateTime.sunday;
    // Cálculo aproximado de la semana del tiempo ordinario
    int ordinaryWeek = 1;
    if (date.isAfter(pentecost)) {
      final daysSincePentecost = date.difference(pentecost).inDays;
      ordinaryWeek = 9 + (daysSincePentecost ~/ 7);
    } else {
      final daysSinceBaptism = date.difference(baptism).inDays;
      ordinaryWeek = 1 + (daysSinceBaptism ~/ 7);
    }

    // Último domingo antes de Adviento = Jesucristo Rey del Universo
    final nextSunday = date.add(Duration(days: (7 - date.weekday) % 7));
    final isChristTheKing = isSunday && nextSunday.add(const Duration(days: 7)).isAfter(advent);

    if (isChristTheKing) {
      return LiturgicalDay(
        fecha: date,
        tiempo: 'Tiempo Ordinario',
        celebracion: 'Jesucristo, Rey del Universo',
        rango: 'solemnidad',
        colorNombre: 'blanco',
        cicloDominical: cicloDom,
        cicloFerial: cicloFer,
        semanaTiempo: 34,
        lecturas: [
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'primera', referencia: 'Dan 7:13-14'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'salmo', referencia: 'Sal 93:1-2, 5'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'segunda', referencia: 'Apoc 1:5-8'),
          DailyReading(fecha: _fmt(date), ciclo: cicloDom, tipo: 'evangelio', referencia: 'Jn 18:33b-37'),
        ],
      );
    }

    return LiturgicalDay(
      fecha: date,
      tiempo: 'Tiempo Ordinario',
      celebracion: isSunday
          ? 'Domingo $ordinaryWeek del Tiempo Ordinario'
          : 'Feria del Tiempo Ordinario, Semana $ordinaryWeek',
      rango: isSunday ? 'solemnidad' : 'feria',
      colorNombre: 'verde',
      cicloDominical: cicloDom,
      cicloFerial: cicloFer,
      semanaTiempo: ordinaryWeek,
      lecturas: _getOrdinaryReadings(date, cicloDom),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static List<DailyReading> _getAdventReadings(DateTime date, String ciclo) {
    return [
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'primera', referencia: 'Isa 2:1-5'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'salmo', referencia: 'Sal 122:1-9'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'evangelio', referencia: 'Mt 8:5-11'),
    ];
  }

  static List<DailyReading> _getChristmasReadings(DateTime date, String ciclo) {
    return [
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'primera', referencia: '1 Jn 1:1-4'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'salmo', referencia: 'Sal 97:1-6'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'evangelio', referencia: 'Jn 20:1a, 2-8'),
    ];
  }

  static List<DailyReading> _getLentReadings(DateTime date, String ciclo) {
    return [
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'primera', referencia: 'Isa 58:1-9a'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'salmo', referencia: 'Sal 51:3-6, 18-19'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'evangelio', referencia: 'Mt 9:14-15'),
    ];
  }

  static List<DailyReading> _getEasterReadings(DateTime date, String ciclo) {
    return [
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'primera', referencia: 'Hch 4:32-35'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'salmo', referencia: 'Sal 118:2-4, 13-15, 22-24'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'evangelio', referencia: 'Jn 3:7b-15'),
    ];
  }

  static List<DailyReading> _getOrdinaryReadings(DateTime date, String ciclo) {
    return [
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'primera', referencia: 'Gál 4:22-24, 26-27, 31-5:1'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'salmo', referencia: 'Sal 113:1-7'),
      DailyReading(fecha: _fmt(date), ciclo: ciclo, tipo: 'evangelio', referencia: 'Lc 11:29-32'),
    ];
  }
}
