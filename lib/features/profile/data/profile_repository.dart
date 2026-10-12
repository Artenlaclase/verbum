import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../bible/data/bible_initial_data.dart';
import '../models/bookmark.dart';
import '../models/reading_history.dart';
import '../models/saved_passage.dart';
import '../models/user_annotation.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  final DatabaseHelper _dbHelper;

  ProfileRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ==================== PERFIL DE USUARIO ====================

  Future<UserProfile> getProfile() async {
    final db = await _dbHelper.database;

    // 1. Si hay base de datos SQLite disponible
    if (db != null) {
      try {
        final maps = await db.query('perfil', where: 'id = ?', whereArgs: [1]);
        if (maps.isNotEmpty) {
          return UserProfile.fromMap(maps.first);
        }
      } catch (e) {
        debugPrint('ProfileRepository getProfile SQLite fallback: $e');
      }
    }

    // 2. Si estamos en Web o respaldo SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('verbum_profile');
    if (profileJson != null) {
      try {
        return UserProfile.fromMap(jsonDecode(profileJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    final defaultProfile = UserProfile(
      id: 1,
      nombre: 'Lector Verbum',
      avatar: '✝️',
      fechaCreacion: DateTime.now(),
      preferencias: {
        'fontSize': 18.0,
        'themeMode': 'system',
        'readerFont': 'Merriweather',
      },
    );

    if (db != null) {
      try {
        await db.insert('perfil', defaultProfile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (_) {}
    }
    await prefs.setString('verbum_profile', jsonEncode(defaultProfile.toMap()));

    // Inicializar marcador y pasaje de bienvenida
    await saveBookmark(Bookmark(
      perfilId: 1,
      libroId: 43, // Juan
      capitulo: 5,
      versiculo: 21,
      modo: 'continuo',
      fechaActualizacion: DateTime.now(),
    ));

    await savePassage(SavedPassage(
      perfilId: 1,
      titulo: 'Amor de Dios',
      referenciaInicio: 'Jn 3:16',
      referenciaFin: 'Jn 3:17',
      libroId: 43,
      capituloInicio: 3,
      versiculoInicio: 16,
      capituloFin: 3,
      versiculoFin: 17,
      textoSnapshot: 'Porque de tal manera amó Dios al mundo, que ha dado á su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.',
      etiqueta: 'Fe',
      color: '#C9A227',
      fechaGuardado: DateTime.now(),
    ));

    return defaultProfile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        await db.update(
          'perfil',
          profile.toMap(),
          where: 'id = ?',
          whereArgs: [profile.id],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verbum_profile', jsonEncode(profile.toMap()));
  }

  // ==================== MARCADOR DE LECTURA CONTINUA ====================

  Future<Bookmark?> getBookmark() async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        final maps = await db.query('marcador_lectura', where: 'perfil_id = ?', whereArgs: [1]);
        if (maps.isNotEmpty) {
          final map = maps.first;
          final libroId = map['libro_id'] as int;
          final book = BibleInitialData.books.firstWhere(
            (b) => b.id == libroId,
            orElse: () => BibleInitialData.books.first,
          );
          return Bookmark.fromMap(
            map,
            libroNombre: book.nombre,
            libroAbreviatura: book.abreviatura,
          );
        }
      } catch (e) {
        debugPrint('ProfileRepository getBookmark SQLite fallback: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final bmJson = prefs.getString('verbum_bookmark');
    if (bmJson != null) {
      try {
        final map = jsonDecode(bmJson) as Map<String, dynamic>;
        final libroId = map['libro_id'] as int;
        final book = BibleInitialData.books.firstWhere(
          (b) => b.id == libroId,
          orElse: () => BibleInitialData.books.first,
        );
        return Bookmark.fromMap(
          map,
          libroNombre: book.nombre,
          libroAbreviatura: book.abreviatura,
        );
      } catch (_) {}
    }

    return Bookmark(
      perfilId: 1,
      libroId: 43,
      capitulo: 5,
      versiculo: 21,
      modo: 'continuo',
      fechaActualizacion: DateTime.now(),
      libroNombre: 'Juan',
      libroAbreviatura: 'Jn',
    );
  }

  Future<void> saveBookmark(Bookmark bookmark) async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        await db.insert(
          'marcador_lectura',
          bookmark.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verbum_bookmark', jsonEncode(bookmark.toMap()));
  }

  // ==================== PASAJES GUARDADOS ====================

  Future<List<SavedPassage>> getSavedPassages({String? etiqueta}) async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        List<Map<String, dynamic>> maps;
        if (etiqueta != null && etiqueta != 'Todos') {
          maps = await db.query(
            'pasajes_guardados',
            where: 'perfil_id = ? AND etiqueta = ?',
            whereArgs: [1, etiqueta],
            orderBy: 'fecha_guardado DESC',
          );
        } else {
          maps = await db.query(
            'pasajes_guardados',
            where: 'perfil_id = ?',
            whereArgs: [1],
            orderBy: 'fecha_guardado DESC',
          );
        }
        if (maps.isNotEmpty) {
          return maps.map((m) => SavedPassage.fromMap(m)).toList();
        }
      } catch (e) {
        debugPrint('ProfileRepository getSavedPassages SQLite fallback: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('verbum_saved_passages') ?? [];
    final passages = listJson.map((str) => SavedPassage.fromMap(jsonDecode(str) as Map<String, dynamic>)).toList();

    if (etiqueta != null && etiqueta != 'Todos') {
      return passages.where((p) => p.etiqueta == etiqueta).toList();
    }
    return passages;
  }

  Future<int> savePassage(SavedPassage passage) async {
    final db = await _dbHelper.database;
    int id = DateTime.now().millisecondsSinceEpoch;
    if (db != null) {
      try {
        id = await db.insert(
          'pasajes_guardados',
          passage.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('verbum_saved_passages') ?? [];
    listJson.insert(0, jsonEncode(passage.toMap()));
    await prefs.setStringList('verbum_saved_passages', listJson);
    return id;
  }

  Future<void> deleteSavedPassage(int id) async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        await db.delete('pasajes_guardados', where: 'id = ?', whereArgs: [id]);
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('verbum_saved_passages') ?? [];
    listJson.removeWhere((str) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return map['id'] == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList('verbum_saved_passages', listJson);
  }

  // ==================== HISTORIAL Y ESTADÍSTICAS ====================

  Future<void> logReading({
    required int libroId,
    required int capitulo,
    int? versiculoInicio,
    int? versiculoFin,
  }) async {
    final db = await _dbHelper.database;
    final logMap = {
      'perfil_id': 1,
      'libro_id': libroId,
      'capitulo': capitulo,
      'versiculo_inicio': versiculoInicio,
      'versiculo_fin': versiculoFin,
      'fecha': DateTime.now().toIso8601String(),
    };

    if (db != null) {
      try {
        await db.insert('historial_lectura', logMap);
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('verbum_history') ?? [];
    listJson.insert(0, jsonEncode(logMap));
    if (listJson.length > 50) listJson.removeLast();
    await prefs.setStringList('verbum_history', listJson);
  }

  Future<List<ReadingHistory>> getReadingHistory({int limit = 30}) async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        final maps = await db.query(
          'historial_lectura',
          where: 'perfil_id = ?',
          whereArgs: [1],
          orderBy: 'fecha DESC',
          limit: limit,
        );
        if (maps.isNotEmpty) {
          return maps.map((m) {
            final libroId = m['libro_id'] as int;
            final book = BibleInitialData.books.firstWhere(
              (b) => b.id == libroId,
              orElse: () => BibleInitialData.books.first,
            );
            return ReadingHistory.fromMap(m, libroNombre: book.nombre);
          }).toList();
        }
      } catch (e) {
        debugPrint('ProfileRepository getReadingHistory SQLite fallback: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('verbum_history') ?? [];
    return listJson.take(limit).map((str) {
      final m = jsonDecode(str) as Map<String, dynamic>;
      final libroId = m['libro_id'] as int;
      final book = BibleInitialData.books.firstWhere(
        (b) => b.id == libroId,
        orElse: () => BibleInitialData.books.first,
      );
      return ReadingHistory.fromMap(m, libroNombre: book.nombre);
    }).toList();
  }

  Future<Map<String, dynamic>> getReadingStats() async {
    final passages = await getSavedPassages();
    final history = await getReadingHistory();

    final uniqueChapters = <String>{};
    for (final h in history) {
      uniqueChapters.add('${h.libroId}-${h.capitulo}');
    }

    final prefs = await SharedPreferences.getInstance();
    final notes = prefs.getStringList('verbum_notes') ?? [];
    final highlights = prefs.getStringList('verbum_highlights') ?? [];

    return {
      'rachaDias': history.isNotEmpty ? 1 : 1,
      'capitulosLeidos': uniqueChapters.isNotEmpty ? uniqueChapters.length : 1,
      'pasajesGuardados': passages.length,
      'anotaciones': notes.length + highlights.length,
    };
  }

  // ==================== SUBRAYADOS Y NOTAS ====================

  Future<void> addHighlight(int versiculoId, String color) async {
    final hlMap = {
      'perfil_id': 1,
      'versiculo_id': versiculoId,
      'color': color,
      'fecha_creacion': DateTime.now().toIso8601String(),
    };

    final db = await _dbHelper.database;
    if (db != null) {
      try {
        await db.insert('subrayados', hlMap, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('verbum_highlights') ?? [];
    list.add(jsonEncode(hlMap));
    await prefs.setStringList('verbum_highlights', list);
  }

  Future<List<UserHighlight>> getHighlightsForChapter(int libroId, int capitulo) async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        final maps = await db.rawQuery('''
          SELECT s.*, v.texto AS versiculo_texto, l.abreviatura || ' ' || v.capitulo || ':' || v.numero AS referencia
          FROM subrayados s
          JOIN versiculos v ON s.versiculo_id = v.id
          JOIN libros l ON v.libro_id = l.id
          WHERE s.perfil_id = 1 AND v.libro_id = ? AND v.capitulo = ?
        ''', [libroId, capitulo]);
        if (maps.isNotEmpty) {
          return maps.map((m) => UserHighlight.fromMap(m)).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  Future<void> addNote(int versiculoId, String contenido) async {
    final noteMap = {
      'perfil_id': 1,
      'versiculo_id': versiculoId,
      'contenido': contenido,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'fecha_modificacion': DateTime.now().toIso8601String(),
    };

    final db = await _dbHelper.database;
    if (db != null) {
      try {
        await db.insert('notas', noteMap, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('verbum_notes') ?? [];
    list.add(jsonEncode(noteMap));
    await prefs.setStringList('verbum_notes', list);
  }

  Future<List<UserNote>> getAllNotes() async {
    final db = await _dbHelper.database;
    if (db != null) {
      try {
        final maps = await db.rawQuery('''
          SELECT n.*, v.texto AS versiculo_texto, l.nombre || ' ' || v.capitulo || ':' || v.numero AS referencia
          FROM notas n
          JOIN versiculos v ON n.versiculo_id = v.id
          JOIN libros l ON v.libro_id = l.id
          WHERE n.perfil_id = 1
          ORDER BY n.fecha_modificacion DESC
        ''');
        if (maps.isNotEmpty) {
          return maps.map((m) => UserNote.fromMap(m)).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  // ==================== EXPORTACIÓN / IMPORTACIÓN JSON ====================

  Future<String> exportBackupJson() async {
    final profile = await getProfile();
    final passages = await getSavedPassages();
    final bookmark = await getBookmark();
    final notes = await getAllNotes();

    final data = {
      'version': '1.1',
      'app': 'Verbum',
      'fechaExportacion': DateTime.now().toIso8601String(),
      'perfil': profile.toMap(),
      'marcador': bookmark?.toMap(),
      'pasajes': passages.map((p) => p.toMap()).toList(),
      'notas': notes.map((n) => n.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importBackupJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (data['perfil'] != null) {
        final profile = UserProfile.fromMap(data['perfil'] as Map<String, dynamic>);
        await updateProfile(profile);
      }
      if (data['marcador'] != null) {
        final bookmark = Bookmark.fromMap(data['marcador'] as Map<String, dynamic>);
        await saveBookmark(bookmark);
      }
      if (data['pasajes'] != null && data['pasajes'] is List) {
        for (final p in data['pasajes']) {
          await savePassage(SavedPassage.fromMap(p as Map<String, dynamic>));
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
