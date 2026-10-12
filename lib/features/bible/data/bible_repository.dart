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

  /// Búsqueda por texto o palabra clave
  Future<List<BibleVerse>> searchVerses(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    final parsed = BibleReferenceParser.parse(clean);
    if (parsed != null) {
      // Búsqueda por cita directa (ej. "Génesis 2:1", "Jn 3:16", "Salmo 23")
      final book = findBookByQuery(parsed.bookQuery);
      if (book != null) {
        final chapterVerses = await getVerses(book.id, parsed.chapter);
        if (parsed.startVerse != null) {
          final end = parsed.endVerse ?? parsed.startVerse!;
          return chapterVerses
              .where((v) => v.numero >= parsed.startVerse! && v.numero <= end)
              .toList();
        }
        return chapterVerses;
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

  BibleBook? findBookByQuery(String query) {
    final clean = query.trim().toLowerCase();
    for (final b in BibleInitialData.books) {
      if (b.nombre.toLowerCase() == clean ||
          b.abreviatura.toLowerCase() == clean ||
          b.nombre.toLowerCase().startsWith(clean) ||
          clean.startsWith(b.nombre.toLowerCase())) {
        return b;
      }
    }
    return null;
  }
}
