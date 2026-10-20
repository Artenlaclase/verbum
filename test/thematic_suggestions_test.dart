import 'package:flutter_test/flutter_test.dart';
import 'package:verbum/core/utils/bible_reference_parser.dart';
import 'package:verbum/features/thematic_suggestions/data/thematic_suggestions_repository.dart';
import 'package:verbum/features/thematic_suggestions/models/thematic_suggestion.dart';

void main() {
  group('ThematicSuggestionsRepository', () {
    final repo = ThematicSuggestionsRepository.instance;

    test('Genera 5 sugerencias diarias para las 5 categorías solicitadas', () {
      final suggestions = repo.getDailySuggestions();
      expect(suggestions.length, 5);

      final categories = suggestions.map((s) => s.category).toSet();
      expect(categories.contains(ThematicCategoryType.amor), isTrue);
      expect(categories.contains(ThematicCategoryType.dinero), isTrue);
      expect(categories.contains(ThematicCategoryType.salud), isTrue);
      expect(categories.contains(ThematicCategoryType.amistad), isTrue);
      expect(categories.contains(ThematicCategoryType.armonia), isTrue);
    });

    test('Todas las citas de sugerencias son válidas y parseables por BibleReferenceParser', () {
      final suggestions = repo.getDailySuggestions();
      for (final s in suggestions) {
        expect(s.referencia, isNotEmpty);
        expect(s.lema, isNotEmpty);
        expect(s.reflexion, isNotEmpty);

        final parsed = BibleReferenceParser.parse(s.referencia);
        expect(parsed, isNotNull,
            reason: 'La cita "${s.referencia}" debe poder ser analizada correctamente');
        expect(parsed!.ranges, isNotEmpty);
      }
    });

    test('La rotación es determinística según la fecha provista', () {
      final date1 = DateTime(2026, 10, 20);
      final date2 = DateTime(2026, 10, 21);

      final s1 = repo.getDailySuggestions(date: date1);
      final s1Repeat = repo.getDailySuggestions(date: date1);
      final s2 = repo.getDailySuggestions(date: date2);

      // Mismo día produce exactamente el mismo resultado
      for (int i = 0; i < 5; i++) {
        expect(s1[i].referencia, equals(s1Repeat[i].referencia));
      }

      // Días distintos rotan los pasajes
      final referencesMatch = s1.map((s) => s.referencia).toList().join(',') ==
          s2.map((s) => s.referencia).toList().join(',');
      expect(referencesMatch, isFalse, reason: 'Días consecutivos deben ofrecer lecturas rotadas');
    });

    test('Permite obtener sugerencia específica para una categoría dada', () {
      final sug = repo.getSuggestionForCategory(ThematicCategoryType.amor);
      expect(sug.category, ThematicCategoryType.amor);
      expect(sug.referencia, isNotEmpty);
    });
  });
}
