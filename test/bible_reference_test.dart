import 'package:flutter_test/flutter_test.dart';
import 'package:verbum/core/utils/bible_reference_parser.dart';
import 'package:verbum/features/bible/data/bible_repository.dart';

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

    test('Parsea referencia litúrgica compleja: Gál 4:22-24, 26-27, 31-5:1', () {
      final ref = BibleReferenceParser.parse('Gál 4:22-24, 26-27, 31-5:1');
      expect(ref, isNotNull);
      expect(ref!.bookQuery, 'Gál');
      expect(ref.ranges.length, 3);

      // Rango 1: 4:22-24
      expect(ref.ranges[0].startChapter, 4);
      expect(ref.ranges[0].startVerse, 22);
      expect(ref.ranges[0].endChapter, 4);
      expect(ref.ranges[0].endVerse, 24);

      // Rango 2: 4:26-27
      expect(ref.ranges[1].startChapter, 4);
      expect(ref.ranges[1].startVerse, 26);
      expect(ref.ranges[1].endChapter, 4);
      expect(ref.ranges[1].endVerse, 27);

      // Rango 3: 4:31 - 5:1 (cruce de capítulo)
      expect(ref.ranges[2].startChapter, 4);
      expect(ref.ranges[2].startVerse, 31);
      expect(ref.ranges[2].endChapter, 5);
      expect(ref.ranges[2].endVerse, 1);
    });

    test('Parsea sufijos de letras: Isa 58:1-9a y Jn 3:7b-15', () {
      final ref1 = BibleReferenceParser.parse('Isa 58:1-9a');
      expect(ref1, isNotNull);
      expect(ref1!.bookQuery, 'Isa');
      expect(ref1.ranges.first.startVerse, 1);
      expect(ref1.ranges.first.endVerse, 9);

      final ref2 = BibleReferenceParser.parse('Jn 3:7b-15');
      expect(ref2, isNotNull);
      expect(ref2!.ranges.first.startVerse, 7);
      expect(ref2.ranges.first.endVerse, 15);
    });

    test('Parsea múltiples rangos y versículos sueltos: Sal 67:2-3, 5, 6, 8', () {
      final ref = BibleReferenceParser.parse('Sal 67:2-3, 5, 6, 8');
      expect(ref, isNotNull);
      expect(ref!.ranges.length, 4);
      expect(ref.ranges[0].startVerse, 2);
      expect(ref.ranges[0].endVerse, 3);
      expect(ref.ranges[1].startVerse, 5);
      expect(ref.ranges[1].endVerse, isNull);
      expect(ref.ranges[2].startVerse, 6);
      expect(ref.ranges[2].endVerse, isNull);
      expect(ref.ranges[3].startVerse, 8);
      expect(ref.ranges[3].endVerse, isNull);
    });

    test('Parsea bloques con punto y coma: Heb 4:14-16; 5:7-9', () {
      final ref = BibleReferenceParser.parse('Heb 4:14-16; 5:7-9');
      expect(ref, isNotNull);
      expect(ref!.ranges.length, 2);
      expect(ref.ranges[0].startChapter, 4);
      expect(ref.ranges[0].startVerse, 14);
      expect(ref.ranges[0].endVerse, 16);
      expect(ref.ranges[1].startChapter, 5);
      expect(ref.ranges[1].startVerse, 7);
      expect(ref.ranges[1].endVerse, 9);
    });

    test('Parsea notación con coma como separador de capítulo: Lc 1, 26-38', () {
      final ref = BibleReferenceParser.parse('Lc 1, 26-38');
      expect(ref, isNotNull);
      expect(ref!.chapter, 1);
      expect(ref.startVerse, 26);
      expect(ref.endVerse, 38);
    });
  });

  group('BibleRepository Book Resolution', () {
    final repo = BibleRepository();

    test('Resuelve libros con y sin tildes, abreviaturas y mayúsculas/minúsculas', () {
      expect(repo.findBookByQuery('Gál')?.id, 48);
      expect(repo.findBookByQuery('Gal')?.id, 48);
      expect(repo.findBookByQuery('gálatas')?.id, 48);
      expect(repo.findBookByQuery('galatas')?.id, 48);
      expect(repo.findBookByQuery('Éxodo')?.id, 2);
      expect(repo.findBookByQuery('exodo')?.id, 2);
      expect(repo.findBookByQuery('Ex')?.id, 2);
      expect(repo.findBookByQuery('Éx')?.id, 2);
      expect(repo.findBookByQuery('Salmo')?.id, 19);
      expect(repo.findBookByQuery('salmos')?.id, 19);
      expect(repo.findBookByQuery('1 Cor')?.id, 46);
      expect(repo.findBookByQuery('1cor')?.id, 46);
      expect(repo.findBookByQuery('1 Jn')?.id, 62);
      expect(repo.findBookByQuery('1jn')?.id, 62);
      expect(repo.findBookByQuery('San Juan')?.id, 43);
    });
  });

  group('BibleRepository Search', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final repo = BibleRepository();

    test('Busca y recupera exactamente los 7 versículos de Gál 4:22-24, 26-27, 31-5:1', () async {
      final results = await repo.searchVerses('Gál 4:22-24, 26-27, 31-5:1');
      expect(results, isNotEmpty);
      expect(results.length, 7);

      expect(results[0].referencia, 'Gál 4:22');
      expect(results[1].referencia, 'Gál 4:23');
      expect(results[2].referencia, 'Gál 4:24');
      expect(results[3].referencia, 'Gál 4:26');
      expect(results[4].referencia, 'Gál 4:27');
      expect(results[5].referencia, 'Gál 4:31');
      expect(results[6].referencia, 'Gál 5:1');

      // Verificar que el versículo que cruza al capítulo 5 contiene su texto canónico
      expect(results[6].texto, contains('ESTAD, pues, firmes en la libertad'));
    });
  });
}
