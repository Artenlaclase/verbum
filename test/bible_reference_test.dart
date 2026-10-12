import 'package:flutter_test/flutter_test.dart';
import 'package:verbum/core/utils/bible_reference_parser.dart';

void main() {
  group('BibleReferenceParser', () {
    test('Parsea citas simples como Jn 3:16', () {
      final ref = BibleReferenceParser.parse('Jn 3:16');
      expect(ref, isNotNull);
      expect(ref!.bookQuery, 'Jn');
      expect(ref.chapter, 3);
      expect(ref.startVerse, 16);
      expect(ref.endVerse, isNull);
    });

    test('Parsea rangos de versículos como Juan 3:16-21', () {
      final ref = BibleReferenceParser.parse('Juan 3:16-21');
      expect(ref, isNotNull);
      expect(ref!.bookQuery, 'Juan');
      expect(ref.chapter, 3);
      expect(ref.startVerse, 16);
      expect(ref.endVerse, 21);
    });

    test('Parsea capítulos completos como Salmo 23', () {
      final ref = BibleReferenceParser.parse('Salmo 23');
      expect(ref, isNotNull);
      expect(ref!.bookQuery, 'Salmo');
      expect(ref.chapter, 23);
      expect(ref.startVerse, isNull);
    });

    test('Parsea libros con número como 1 Cor 13:4-8', () {
      final ref = BibleReferenceParser.parse('1 Cor 13:4-8');
      expect(ref, isNotNull);
      expect(ref!.bookQuery, '1 Cor');
      expect(ref.chapter, 13);
      expect(ref.startVerse, 4);
      expect(ref.endVerse, 8);
    });
  });
}
