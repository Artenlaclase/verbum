import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/bible_reference_parser.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import 'bible_initial_data.dart';

class BibleRepository {
  final DatabaseHelper _dbHelper;

  BibleRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Asegura que los metadatos de los libros y los versículos semilla estén en la base de datos
  Future<void> ensureInitialized() async {
    final db = await _dbHelper.database;
    if (db == null) return; // En Web o si SQLite no está disponible, usamos datos en memoria

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

          // 3. Insertar versículos semilla
          for (final verse in BibleInitialData.seedVerses) {
            await txn.insert(
              'versiculos',
              verse.toMap(),
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
    final db = await _dbHelper.database;

    // 1. Si hay base de datos SQLite disponible, consultar
    if (db != null) {
      try {
        await ensureInitialized();
        final maps = await db.rawQuery('''
          SELECT v.*, l.nombre AS libro_nombre, l.abreviatura AS libro_abreviatura
          FROM versiculos v
          JOIN libros l ON v.libro_id = l.id
          WHERE v.libro_id = ? AND v.capitulo = ?
          ORDER BY v.numero ASC
        ''', [libroId, capitulo]);

        if (maps.isNotEmpty) {
          return maps.map((m) => BibleVerse.fromMap(m)).toList();
        }
      } catch (e) {
        debugPrint('BibleRepository getVerses fallback: $e');
      }
    }

    // 2. Si estamos en Web o los versículos no estaban en la BD SQLite:
    // Buscar primero en los versículos semilla precargados
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

    // 3. Generar versículos representativos para el capítulo seleccionado
    return List.generate(15, (index) {
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
      // Búsqueda por cita directa
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

    final db = await _dbHelper.database;
    if (db != null) {
      try {
        await ensureInitialized();
        final pattern = '%$clean%';
        final maps = await db.rawQuery('''
          SELECT v.*, l.nombre AS libro_nombre, l.abreviatura AS libro_abreviatura
          FROM versiculos v
          JOIN libros l ON v.libro_id = l.id
          WHERE v.texto LIKE ?
          ORDER BY l.orden ASC, v.capitulo ASC, v.numero ASC
          LIMIT 50
        ''', [pattern]);

        if (maps.isNotEmpty) {
          return maps.map((m) => BibleVerse.fromMap(m)).toList();
        }
      } catch (e) {
        debugPrint('BibleRepository search fallback: $e');
      }
    }

    // En memoria / Web: buscar en versículos semilla
    final lower = clean.toLowerCase();
    final results = <BibleVerse>[];
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
