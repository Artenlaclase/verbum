import 'package:flutter_test/flutter_test.dart';
import 'package:verbum/features/liturgical_calendar/data/liturgical_calculator.dart';
import 'package:verbum/core/theme/liturgical_colors.dart';

void main() {
  group('LiturgicalCalculator - Meeus/Jones/Butcher Computus', () {
    test('Calcula correctamente el Domingo de Pascua para años clave', () {
      // 2024: 31 de marzo
      final easter2024 = LiturgicalCalculator.getEasterSunday(2024);
      expect(easter2024.year, 2024);
      expect(easter2024.month, 3);
      expect(easter2024.day, 31);

      // 2025: 20 de abril
      final easter2025 = LiturgicalCalculator.getEasterSunday(2025);
      expect(easter2025.year, 2025);
      expect(easter2025.month, 4);
      expect(easter2025.day, 20);

      // 2026: 5 de abril
      final easter2026 = LiturgicalCalculator.getEasterSunday(2026);
      expect(easter2026.year, 2026);
      expect(easter2026.month, 4);
      expect(easter2026.day, 5);
    });

    test('Navidad y Santa María Madre de Dios tienen rango solemnidad y color blanco', () {
      final maryMotherOfGod = LiturgicalCalculator.getLiturgicalDay(DateTime.utc(2026, 1, 1));
      expect(maryMotherOfGod.celebracion, 'Santa María, Madre de Dios');
      expect(maryMotherOfGod.colorNombre, 'blanco');
      expect(maryMotherOfGod.color, LiturgicalColors.blanco);
      expect(maryMotherOfGod.isSolemnidad, true);

      final christmas = LiturgicalCalculator.getLiturgicalDay(DateTime.utc(2026, 12, 25));
      expect(christmas.celebracion.contains('Natividad'), true);
      expect(christmas.colorNombre, 'blanco');
      expect(christmas.color, LiturgicalColors.blanco);
    });

    test('Miércoles de Ceniza y Viernes Santo tienen colores litúrgicos canónicos', () {
      final easter2026 = LiturgicalCalculator.getEasterSunday(2026);
      final ashWednesday = easter2026.subtract(const Duration(days: 46));
      final ashDay = LiturgicalCalculator.getLiturgicalDay(ashWednesday);
      expect(ashDay.celebracion, 'Miércoles de Ceniza');
      expect(ashDay.colorNombre, 'morado');
      expect(ashDay.color, LiturgicalColors.morado);

      final goodFriday = easter2026.subtract(const Duration(days: 2));
      final goodFridayDay = LiturgicalCalculator.getLiturgicalDay(goodFriday);
      expect(goodFridayDay.colorNombre, 'rojo');
      expect(goodFridayDay.color, LiturgicalColors.rojo);
    });
  });
}
