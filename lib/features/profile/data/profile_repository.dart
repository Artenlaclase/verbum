import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_sync_service.dart';
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

  bool get _isAuthenticated => AuthService.instance.isSignedIn;
  FirestoreSyncService get _firestore => FirestoreSyncService.instance;

  // ==================== LIMPIEZA AL CERRAR SESIÓN (VOLVER A CERO) ====================

  /// Limpia todos los datos locales para que la aplicación vuelva a cero al cerrar sesión.
  Future<void> clearLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('verbum_profile');
      await prefs.remove('verbum_bookmark');
      await prefs.remove('verbum_saved_passages');
      await prefs.remove('verbum_history');
      await prefs.remove('verbum_highlights');
      await prefs.remove('verbum_notes');

      final db = await _dbHelper.database;
      if (db != null) {
        await db.delete('perfil');
        await db.delete('marcador_lectura');
        await db.delete('pasajes_guardados');
        await db.delete('historial_lectura');
        await db.delete('subrayados');
        await db.delete('notas');
      }
    } catch (e) {
      debugPrint('ProfileRepository clearLocalUserData warning: $e');
    }
  }

  // ==================== PERFIL DE USUARIO ====================

  Future<UserProfile> getProfile() async {
    final defaultProfile = UserProfile(
      id: 1,
      nombre: _isAuthenticated
          ? (AuthService.instance.currentUser?.displayName ??
              AuthService.instance.currentUser?.email?.split('@').first ??
              'Lector Verbum')
          : 'Lector Verbum',
      avatar: '✝️',
      fechaCreacion: DateTime.now(),
      preferencias: {
        'fontSize': 18.0,
        'themeMode': 'system',
        'readerFont': 'Merriweather',
      },
    );

    // Si NO hay sesión iniciada, la app permanece en estado cero (Invitado)
    if (!_isAuthenticated) {
      return defaultProfile;
    }

    // 1. Si hay usuario autenticado, consultar Firestore primero
    try {
      final cloudProfile = await _firestore.getProfile();
      if (cloudProfile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('verbum_profile', jsonEncode(cloudProfile.toMap()));
        return cloudProfile;
      }
    } catch (e) {
      debugPrint('ProfileRepository getProfile Firestore fallback: $e');
    }

    // 2. Si es un usuario autenticado nuevo en Firestore, inicializar su perfil limpio y marcador en Génesis 1:1
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verbum_profile', jsonEncode(defaultProfile.toMap()));
    unawaited(_firestore.saveProfile(defaultProfile));
    unawaited(_firestore.saveBookmark(_defaultZeroBookmark()));

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

    if (_isAuthenticated) {
      unawaited(_firestore.saveProfile(profile));
    }
  }

  // ==================== MARCADOR DE LECTURA CONTINUA ====================

  Bookmark _defaultZeroBookmark() {
    return Bookmark(
      perfilId: 1,
      libroId: 1,
      capitulo: 1,
      versiculo: 1,
      modo: 'continuo',
      fechaActualizacion: DateTime.now(),
      libroNombre: 'Génesis',
      libroAbreviatura: 'Gn',
    );
  }

  bool _isLegacySeedBookmark(Bookmark bm) {
    return bm.libroId == 43 && bm.capitulo == 5 && bm.versiculo == 21;
  }

  Future<Bookmark?> getBookmark() async {
    // Si no ha iniciado sesión, el Modo Corrido empieza siempre en cero (Génesis 1:1)
    if (!_isAuthenticated) {
      return _defaultZeroBookmark();
    }

    // 1. Firestore si autenticado
    try {
      final cloudBookmark = await _firestore.getBookmark();
      if (cloudBookmark != null) {
        if (_isLegacySeedBookmark(cloudBookmark)) {
          final zero = _defaultZeroBookmark();
          unawaited(saveBookmark(zero));
          return zero;
        }
        return cloudBookmark;
      }
    } catch (e) {
      debugPrint('ProfileRepository getBookmark Firestore fallback: $e');
    }

    // 2. Respaldo local (solo para la sesión activa)
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
        final bm = Bookmark.fromMap(
          map,
          libroNombre: book.nombre,
          libroAbreviatura: book.abreviatura,
        );
        if (_isLegacySeedBookmark(bm)) {
          final zero = _defaultZeroBookmark();
          unawaited(saveBookmark(zero));
          return zero;
        }
        return bm;
      } catch (_) {}
    }

    return _defaultZeroBookmark();
  }

  Future<void> saveBookmark(Bookmark bookmark) async {
    if (!_isAuthenticated) return;

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

    unawaited(_firestore.saveBookmark(bookmark));
  }

  // ==================== PASAJES GUARDADOS (REQUIERE SESIÓN) ====================

  Future<List<SavedPassage>> getSavedPassages({String? etiqueta}) async {
    // Sin sesión activa no se muestran ni guardan pasajes
    if (!_isAuthenticated) return [];

    // 1. Firestore
    try {
      final cloudPassages = await _firestore.getSavedPassages(etiqueta: etiqueta);
      if (cloudPassages.isNotEmpty) return cloudPassages;
    } catch (e) {
      debugPrint('ProfileRepository getSavedPassages Firestore fallback: $e');
    }

    // 2. Respaldo local de la sesión activa
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getStringList('verbum_saved_passages') ?? [];
    final passages = listJson
        .map((str) => SavedPassage.fromMap(jsonDecode(str) as Map<String, dynamic>))
        .toList();

    if (etiqueta != null && etiqueta != 'Todos') {
      return passages.where((p) => p.etiqueta == etiqueta).toList();
    }
    return passages;
  }

  Future<int> savePassage(SavedPassage passage) async {
    if (!_isAuthenticated) return -1;

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

    unawaited(_firestore.savePassage(passage));
    return id;
  }

  Future<void> deleteSavedPassage(int id) async {
    if (!_isAuthenticated) return;

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

  // ==================== HISTORIAL Y ESTADÍSTICAS (REQUIERE SESIÓN) ====================

  Future<void> logReading({
    required int libroId,
    required int capitulo,
    int? versiculoInicio,
    int? versiculoFin,
  }) async {
    if (!_isAuthenticated) return;

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

    unawaited(_firestore.logReading(logMap));
  }

  Future<List<ReadingHistory>> getReadingHistory({int limit = 30}) async {
    if (!_isAuthenticated) return [];

    // 1. Firestore
    try {
      final cloudHistory = await _firestore.getReadingHistory(limit: limit);
      if (cloudHistory.isNotEmpty) return cloudHistory;
    } catch (e) {
      debugPrint('ProfileRepository getReadingHistory Firestore fallback: $e');
    }

    // 2. Respaldo local de la sesión activa
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
    if (!_isAuthenticated) {
      return {
        'rachaDias': 0,
        'capitulosLeidos': 0,
        'pasajesGuardados': 0,
        'anotaciones': 0,
      };
    }

    final passages = await getSavedPassages();
    final history = await getReadingHistory();

    final uniqueChapters = <String>{};
    for (final h in history) {
      uniqueChapters.add('${h.libroId}-${h.capitulo}');
    }

    final prefs = await SharedPreferences.getInstance();
    final notes = prefs.getStringList('verbum_notes') ?? [];
    final highlights = prefs.getStringList('verbum_highlights') ?? [];
    final localAnnotations = notes.length + highlights.length;
    final cloudAnnotations = await _firestore.getAnnotationsCount();

    return {
      'rachaDias': history.isNotEmpty ? 1 : 0,
      'capitulosLeidos': uniqueChapters.length,
      'pasajesGuardados': passages.length,
      'anotaciones': cloudAnnotations > localAnnotations ? cloudAnnotations : localAnnotations,
    };
  }

  // ==================== SUBRAYADOS Y NOTAS (REQUIERE SESIÓN) ====================

  Future<void> addHighlight(int versiculoId, String color) async {
    if (!_isAuthenticated) return;

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

    unawaited(_firestore.addHighlight(hlMap));
  }

  Future<List<UserHighlight>> getHighlightsForChapter(int libroId, int capitulo) async {
    if (!_isAuthenticated) return [];

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
    if (!_isAuthenticated) return;

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

    unawaited(_firestore.addNote(noteMap));
  }

  Future<List<UserNote>> getAllNotes() async {
    if (!_isAuthenticated) return [];

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
