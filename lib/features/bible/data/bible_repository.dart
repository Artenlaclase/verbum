import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/bible_reference_parser.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import 'bible_initial_data.dart';

class BibleRepository {
  final DatabaseHelper _dbHelper;
  final Map<int, Map<String, dynamic>> _loadedBooksCache = {};

  BibleRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Carga bajo demanda el archivo JSON del libro desde los assets empaquetados
  Future<Map<String, dynamic>?> _loadBookJson(int libroId) async {
    if (_loadedBooksCache.containsKey(libroId)) {
      return _loadedBooksCache[libroId];
    }
    try {
      final jsonString = await rootBundle.loadString('assets/bible/books/$libroId.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      _loadedBooksCache[libroId] = data;
      return data;
    } catch (e) {
      debugPrint('No se pudo cargar asset para libro $libroId: $e');
      return null;
    }
  }

  /// Asegura que los metadatos de los libros y los versículos semilla estén en la base de datos
  Future<void> ensureInitialized() async {
    final db = await _dbHelper.database;
    if (db == null) return; // En Web o si SQLite no está disponible, usamos datos en memoria y assets

    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM libros'),
      );

      if (count == null || count == 0) {
        await db.transaction((txn) async {
          // 1. Insertar versión RVR09
          await txn.insert(
            'versiones',
            BibleInitialData.versionRVR09,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // 2. Insertar los 66 libros
          for (final book in BibleInitialData.books) {
            await txn.insert(
              'libros',
              book.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('BibleRepository init warning: $e');
    }
  }

  /// Retorna la lista de todos los libros ordenados canónicamente
  Future<List<BibleBook>> getBooks({String? testamento}) async {
    final db = await _dbHelper.database;

    // En Web o como respaldo infalible
    if (db == null) {
      if (testamento != null) {
        return BibleInitialData.books.where((b) => b.testamento == testamento).toList();
      }
      return BibleInitialData.books;
    }

    try {
      await ensureInitialized();
      List<Map<String, dynamic>> maps;
      if (testamento != null) {
        maps = await db.query(
          'libros',
          where: 'testamento = ?',
          whereArgs: [testamento],
          orderBy: 'orden ASC',
        );
      } else {
        maps = await db.query('libros', orderBy: 'orden ASC');
      }

      if (maps.isNotEmpty) {
        return maps.map((map) {
          final book = BibleInitialData.books.firstWhere(
            (b) => b.id == map['id'],
            orElse: () => BibleBook.fromMap(map),
          );
          return book;
        }).toList();
      }
    } catch (e) {
      debugPrint('BibleRepository getBooks fallback: $e');
    }

    if (testamento != null) {
      return BibleInitialData.books.where((b) => b.testamento == testamento).toList();
    }
    return BibleInitialData.books;
  }

  /// Obtiene un libro por su ID
  Future<BibleBook?> getBookById(int id) async {
    try {
      return BibleInitialData.books.firstWhere((b) => b.id == id);
    } catch (_) {
      final db = await _dbHelper.database;
      if (db != null) {
        try {
          final maps = await db.query('libros', where: 'id = ?', whereArgs: [id]);
          if (maps.isNotEmpty) {
            return BibleBook.fromMap(maps.first);
          }
        } catch (_) {}
      }
      return null;
    }
  }

  /// Obtiene los versículos de un libro y capítulo específico
  Future<List<BibleVerse>> getVerses(int libroId, int capitulo) async {
    final book = await getBookById(libroId);

    // 1. Cargar desde los archivos JSON empaquetados de la Biblia (RVR09 completo)
    final bookData = await _loadBookJson(libroId);
    if (bookData != null) {
      final chapKey = '$capitulo';
      if (bookData.containsKey(chapKey)) {
        final versesMap = bookData[chapKey] as Map<String, dynamic>;
        final versesList = <BibleVerse>[];
        final sortedKeys = versesMap.keys.map(int.parse).toList()..sort();

        for (final num in sortedKeys) {
          final text = versesMap['$num'] as String;
          versesList.add(BibleVerse(
            id: (libroId * 100000) + (capitulo * 1000) + num,
            libroId: libroId,
            capitulo: capitulo,
            numero: num,
            texto: text,
            libroNombre: book?.nombre,
            libroAbreviatura: book?.abreviatura,
          ));
        }

        if (versesList.isNotEmpty) {
          return versesList;
        }
      }
    }

    // 2. Si no se encontró en los JSON empaquetados, buscar en los versículos semilla iniciales
    final inMemoryMatches = BibleInitialData.seedVerses
        .where((v) => v.libroId == libroId && v.capitulo == capitulo)
        .map((v) => BibleVerse(
              id: v.id,
              libroId: v.libroId,
              capitulo: v.capitulo,
              numero: v.numero,
              texto: v.texto,
              libroNombre: book?.nombre,
              libroAbreviatura: book?.abreviatura,
            ))
        .toList();

    if (inMemoryMatches.isNotEmpty) {
      return inMemoryMatches;
    }

    // 3. Si por algún motivo extremo no se encontrara el archivo
    return List.generate(10, (index) {
      final num = index + 1;
      return BibleVerse(
        id: (libroId * 10000) + (capitulo * 100) + num,
        libroId: libroId,
        capitulo: capitulo,
        numero: num,
        texto: '[$num] Texto bíblico de ${book?.nombre ?? "Libro"} $capitulo:$num (RVR09).',
        libroNombre: book?.nombre,
        libroAbreviatura: book?.abreviatura,
      );
    });
  }

  /// Búsqueda por cita bíblica o texto clave
  Future<List<BibleVerse>> searchVerses(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    final parsed = BibleReferenceParser.parse(clean);
    if (parsed != null) {
      final book = findBookByQuery(parsed.bookQuery);
      if (book != null) {
        return await getVersesForReference(book, parsed);
      }
    }

    final lower = clean.toLowerCase();
    final results = <BibleVerse>[];

    // Buscar en los libros más consultados o en la semilla
    for (final v in BibleInitialData.seedVerses) {
      if (v.texto.toLowerCase().contains(lower)) {
        final book = await getBookById(v.libroId);
        results.add(BibleVerse(
          id: v.id,
          libroId: v.libroId,
          capitulo: v.capitulo,
          numero: v.numero,
          texto: v.texto,
          libroNombre: book?.nombre,
          libroAbreviatura: book?.abreviatura,
        ));
      }
    }

    return results;
  }

  /// Obtiene todos los versículos cubiertos por una cita bíblica parseada
  Future<List<BibleVerse>> getVersesForReference(
    BibleBook book,
    ParsedBibleReference parsed,
  ) async {
    final results = <BibleVerse>[];
    final seenVerseKeys = <String>{};

    for (final range in parsed.ranges) {
      if (range.startChapter == range.endChapter) {
        final chapterVerses = await getVerses(book.id, range.startChapter);
        if (range.startVerse == null) {
          // Capítulo completo
          for (final v in chapterVerses) {
            final key = '${v.capitulo}:${v.numero}';
            if (seenVerseKeys.add(key)) results.add(v);
          }
        } else {
          final startV = range.startVerse!;
          final endV = range.endVerse ?? startV;
          final matched = chapterVerses.where(
            (v) => v.numero >= startV && v.numero <= endV,
          );
          for (final v in matched) {
            final key = '${v.capitulo}:${v.numero}';
            if (seenVerseKeys.add(key)) results.add(v);
          }
        }
      } else {
        // Rango que cruza capítulos (ej: 4:31-5:1)
        for (int ch = range.startChapter; ch <= range.endChapter; ch++) {
          final chapterVerses = await getVerses(book.id, ch);
          if (ch == range.startChapter) {
            final startV = range.startVerse ?? 1;
            final matched = chapterVerses.where((v) => v.numero >= startV);
            for (final v in matched) {
              final key = '${v.capitulo}:${v.numero}';
              if (seenVerseKeys.add(key)) results.add(v);
            }
          } else if (ch == range.endChapter) {
            final endV = range.endVerse ?? (chapterVerses.isNotEmpty ? chapterVerses.last.numero : 999);
            final matched = chapterVerses.where((v) => v.numero <= endV);
            for (final v in matched) {
              final key = '${v.capitulo}:${v.numero}';
              if (seenVerseKeys.add(key)) results.add(v);
            }
          } else {
            // Capítulos intermedios completos
            for (final v in chapterVerses) {
              final key = '${v.capitulo}:${v.numero}';
              if (seenVerseKeys.add(key)) results.add(v);
            }
          }
        }
      }
    }

    return results;
  }

  BibleBook? findBookByQuery(String query) {
    final clean = _normalize(query);
    if (clean.isEmpty) return null;

    // 1. Coincidencia exacta con abreviatura normalizada
    for (final b in BibleInitialData.books) {
      if (_normalize(b.abreviatura) == clean) {
        return b;
      }
    }

    // 2. Coincidencia exacta con nombre normalizado
    for (final b in BibleInitialData.books) {
      if (_normalize(b.nombre) == clean) {
        return b;
      }
    }

    // 3. Diccionario de alias comunes
    final aliasId = _bookAliases[clean];
    if (aliasId != null) {
      try {
        return BibleInitialData.books.firstWhere((b) => b.id == aliasId);
      } catch (_) {}
    }

    // 4. Prefijo en nombre o abreviatura
    for (final b in BibleInitialData.books) {
      final normName = _normalize(b.nombre);
      final normAbbr = _normalize(b.abreviatura);
      if (normName.startsWith(clean) || (clean.length >= 2 && normAbbr.startsWith(clean))) {
        return b;
      }
    }

    // 5. Inverso: Si la query empieza con el nombre completo
    for (final b in BibleInitialData.books) {
      final normName = _normalize(b.nombre);
      if (clean.startsWith(normName)) {
        return b;
      }
    }

    return null;
  }

  static String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'^(san|santo|santa)\s+'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static const Map<String, int> _bookAliases = {
    'salmo': 19,
    'salmos': 19,
    'ps': 19,
    'psalm': 19,
    'cantar': 22,
    'cantares': 22,
    'ap': 66,
    'apoc': 66,
    'apocalipsis': 66,
    'revelacion': 66,
    'revelaciones': 66,
    'act': 44,
    'actos': 44,
    'hechos': 44,
    'qoh': 21,
    'qohelet': 21,
    'ec': 21,
    'dt': 5,
    'deu': 5,
    'flp': 50,
    'php': 50,
    'stg': 59,
    'stgo': 59,
    'jas': 59,
    'phm': 57,
    '1th': 52,
    '2th': 53,
    '1ti': 54,
    '2ti': 55,
    '1p': 60,
    '2p': 61,
    '1j': 62,
    '2j': 63,
    '3j': 64,
    'ga': 48,
  };
}
