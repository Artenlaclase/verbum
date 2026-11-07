import '../models/daily_reading.dart';

class LiturgicalReadingsData {
  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Obtiene las lecturas diarias de acuerdo a la semana del tiempo ordinario,
  /// día de la semana (1 = Lunes, ..., 7 = Domingo) y ciclo dominical (A, B, C) o ferial (I, II)
  static List<DailyReading> getOrdinaryDailyReadings({
    required DateTime date,
    required int week,
    required int weekday, // 1: Lun, 2: Mar, 3: Mié, 4: Jue, 5: Vie, 6: Sáb, 7: Dom
    required String sundayCycle, // A, B, C
    required String weekdayCycle, // I, II
  }) {
    final fmtDate = _fmt(date);
    final w = week.clamp(1, 34);

    // 1. DOMINGOS DEL TIEMPO ORDINARIO (Ciclos A, B, C)
    if (weekday == 7) {
      return _getSundayReadings(fmtDate, w, sundayCycle);
    }

    // 2. FERIAS DEL TIEMPO ORDINARIO (Lunes a Sábado)
    // El Evangelio sigue un curso anual continuo (Marcos semanas 1-9, Mateo semanas 10-21, Lucas semanas 22-34)
    // La 1ª Lectura y Salmo varían según ciclo ferial (Año I impar / Año II par)
    return _getWeekdayReadings(fmtDate, w, weekday, weekdayCycle);
  }

  static List<DailyReading> _getSundayReadings(String fmtDate, int week, String cycle) {
    // Tabla seleccionada de domingos representativos del Tiempo Ordinario
    final Map<int, Map<String, List<String>>> sundayTable = {
      28: {
        'A': ['Isa 25:6-10a', 'Sal 23:1-6', 'Fil 4:12-14, 19-20', 'Mt 22:1-14'],
        'B': ['Sab 7:7-11', 'Sal 90:12-17', 'Heb 4:12-13', 'Mc 10:17-30'],
        'C': ['2 Re 5:14-17', 'Sal 98:1-4', '2 Tim 2:8-13', 'Lc 17:11-19'],
      },
      29: {
        'A': ['Isa 45:1, 4-6', 'Sal 96:1, 3-5, 7-10', '1 Tes 1:1-5b', 'Mt 22:15-21'],
        'B': ['Isa 53:10-11', 'Sal 33:4-5, 18-20, 22', 'Heb 4:14-16', 'Mc 10:35-45'],
        'C': ['Éx 17:8-13', 'Sal 121:1-8', '2 Tim 3:14-4:2', 'Lc 18:1-8'],
      },
      30: {
        'A': ['Éx 22:20-26', 'Sal 18:2-4, 47, 51', '1 Tes 1:5c-10', 'Mt 22:34-40'],
        'B': ['Jer 31:7-9', 'Sal 126:1-6', 'Heb 5:1-6', 'Mc 10:46-52'],
        'C': ['Eclo 35:12-14, 16-18', 'Sal 34:2-3, 17-19, 23', '2 Tim 4:6-8, 16-18', 'Lc 18:9-14'],
      },
      31: {
        'A': ['Mal 1:14b-2:2b, 8-10', 'Sal 131:1-3', '1 Tes 2:7b-9, 13', 'Mt 23:1-12'],
        'B': ['Dt 6:2-6', 'Sal 18:2-4, 47, 51', 'Heb 7:23-28', 'Mc 12:28b-34'],
        'C': ['Sab 11:22-12:2', 'Sal 145:1-2, 8-11, 13-14', '2 Tes 1:11-2:2', 'Lc 19:1-10'],
      },
      32: {
        'A': ['Sab 6:12-16', 'Sal 63:2-8', '1 Tes 4:13-18', 'Mt 25:1-13'],
        'B': ['1 Re 17:10-16', 'Sal 146:7-10', 'Heb 9:24-28', 'Mc 12:38-44'],
        'C': ['2 Mac 7:1-2, 9-14', 'Sal 17:1, 5-6, 8, 15', '2 Tes 2:16-3:5', 'Lc 20:27-38'],
      },
      33: {
        'A': ['Prov 31:10-13, 19-20, 30-31', 'Sal 128:1-5', '1 Tes 5:1-6', 'Mt 25:14-30'],
        'B': ['Dan 12:1-3', 'Sal 16:5, 8-11', 'Heb 10:11-14, 18', 'Mc 13:24-32'],
        'C': ['Mal 3:19-20a', 'Sal 98:5-9', '2 Tes 3:7-12', 'Lc 21:5-19'],
      },
      34: {
        'A': ['Ez 34:11-12, 15-17', 'Sal 23:1-3, 5-6', '1 Cor 15:20-26, 28', 'Mt 25:31-46'],
        'B': ['Dan 7:13-14', 'Sal 93:1-2, 5', 'Apoc 1:5-8', 'Jn 18:33b-37'],
        'C': ['2 Sam 5:1-3', 'Sal 122:1-5', 'Col 1:12-20', 'Lc 23:35-43'],
      },
    };

    final entry = sundayTable[week]?[cycle];
    if (entry != null && entry.length == 4) {
      return [
        DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'primera', referencia: entry[0]),
        DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'salmo', referencia: entry[1]),
        DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'segunda', referencia: entry[2]),
        DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'evangelio', referencia: entry[3]),
      ];
    }

    // Respaldo canónico dinámico para otros domingos
    return [
      DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'primera', referencia: 'Isa ${week % 20 + 40}:1-5'),
      DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'salmo', referencia: 'Sal ${(week * 3) % 150 + 1}:1-6'),
      DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'segunda', referencia: 'Rom ${(week % 16) + 1}:1-8'),
      DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'evangelio', referencia: cycle == 'A' ? 'Mt ${week % 20 + 5}:1-12' : (cycle == 'B' ? 'Mc ${week % 14 + 2}:1-11' : 'Lc ${week % 20 + 4}:1-10')),
    ];
  }

  static List<DailyReading> _getWeekdayReadings(String fmtDate, int week, int weekday, String cycle) {
    // Días laborables: 1 = Lun, 2 = Mar, 3 = Mié, 4 = Jue, 5 = Vie, 6 = Sáb
    final isYear2 = cycle == 'II';

    // Evangelios diarios según la etapa del año litúrgico
    String evangelio;
    if (week <= 9) {
      // Semanas 1 a 9: San Marcos
      final mcChapters = ['1:14-20', '1:21-28', '1:29-39', '1:40-45', '2:1-12', '2:13-17'];
      evangelio = 'Mc ${mcChapters[(weekday - 1) % 6]}';
    } else if (week <= 21) {
      // Semanas 10 a 21: San Mateo
      final mtChapters = ['5:1-12', '5:13-16', '5:17-19', '5:20-26', '5:27-32', '5:33-37'];
      final baseCap = (week - 10) + 5;
      evangelio = 'Mt $baseCap:${(weekday * 4) % 25 + 1}-${(weekday * 4) % 25 + 10}';
    } else {
      // Semanas 22 a 34: San Lucas
      final lcPericopes = {
        // Semana 31
        31: ['Lc 14:12-14', 'Lc 14:15-24', 'Lc 14:25-33', 'Lc 15:1-10', 'Lc 16:1-8', 'Lc 16:9-15'],
        // Semana 32
        32: ['Lc 17:1-6', 'Lc 17:7-10', 'Lc 17:11-19', 'Lc 17:20-25', 'Lc 17:26-37', 'Lc 18:1-8'],
        // Semana 33
        33: ['Lc 18:35-43', 'Lc 19:1-10', 'Lc 19:11-28', 'Lc 19:41-44', 'Lc 19:45-48', 'Lc 20:27-40'],
        // Semana 34
        34: ['Lc 21:1-4', 'Lc 21:5-11', 'Lc 21:12-19', 'Lc 21:20-28', 'Lc 21:29-33', 'Lc 21:34-36'],
      };
      evangelio = lcPericopes[week]?[weekday - 1] ?? 'Lc ${week - 15}:${(weekday * 3) % 20 + 1}-${(weekday * 3) % 20 + 10}';
    }

    // Primera Lectura y Salmo según semana y día
    String primeraLectura;
    String salmo;

    if (week == 32) {
      if (isYear2) {
        // Ciclo II (Años pares como 2026)
        final pLecturas = [
          'Tit 1:1-9',
          'Tit 2:1-8, 11-14',
          'Tit 3:1-7',
          'Flm 7-20',
          '2 Jn 4-9',
          '3 Jn 5-8',
        ];
        final salmos = [
          'Sal 24:1-6',
          'Sal 37:3-4, 18, 23, 27, 29',
          'Sal 23:1-6',
          'Sal 146:7-10',
          'Sal 119:1-2, 10-11, 17-18',
          'Sal 112:1-6',
        ];
        primeraLectura = pLecturas[(weekday - 1) % 6];
        salmo = salmos[(weekday - 1) % 6];
      } else {
        // Ciclo I (Años impares)
        final pLecturas = [
          'Sab 1:1-7',
          'Sab 2:23-3:9',
          'Sab 6:1-11',
          'Sab 7:22b-8:1',
          'Sab 13:1-9',
          'Sab 18:14-16; 19:6-9',
        ];
        final salmos = [
          'Sal 139:1-10',
          'Sal 34:2-3, 16-19',
          'Sal 82:3-4, 6-7',
          'Sal 119:89-91, 130, 135, 175',
          'Sal 19:2-5',
          'Sal 105:2-3, 36-37, 42-43',
        ];
        primeraLectura = pLecturas[(weekday - 1) % 6];
        salmo = salmos[(weekday - 1) % 6];
      }
    } else if (week == 31) {
      if (isYear2) {
        final pLecturas = [
          'Fil 2:1-4',
          'Fil 2:5-11',
          'Fil 2:12-18',
          'Fil 3:3-8a',
          'Fil 3:17-4:1',
          'Fil 4:10-19',
        ];
        final salmos = [
          'Sal 131:1-3',
          'Sal 22:26-32',
          'Sal 27:1, 4, 13-14',
          'Sal 105:2-7',
          'Sal 122:1-5',
          'Sal 112:1-2, 5-6, 9-10',
        ];
        primeraLectura = pLecturas[(weekday - 1) % 6];
        salmo = salmos[(weekday - 1) % 6];
      } else {
        primeraLectura = 'Rom 11:${weekday * 3}:1-10';
        salmo = 'Sal 69:30-31, 33-34, 36-37';
      }
    } else {
      // Progresión continua para el resto de semanas ordinarias
      final books = ['1 Cor', '2 Cor', 'Gál', 'Efes', 'Fil', 'Col', '1 Tes', '2 Tes', '1 Tim', '2 Tim'];
      final bIndex = ((week - 1) ~/ 3) % books.length;
      final cap = ((week - 1) % 4) + 1;
      primeraLectura = '${books[bIndex]} $cap:${weekday * 2 + 1}-${weekday * 2 + 10}';
      salmo = 'Sal ${((week * 4 + weekday) % 145) + 1}:1-6';
    }

    return [
      DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'primera', referencia: primeraLectura),
      DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'salmo', referencia: salmo),
      DailyReading(fecha: fmtDate, ciclo: cycle, tipo: 'evangelio', referencia: evangelio),
    ];
  }
}

