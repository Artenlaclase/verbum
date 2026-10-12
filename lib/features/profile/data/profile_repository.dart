import 'dart:convert';
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

  /// Obtiene o inicializa el perfil de usuario local (sin backend en MVP)
  Future<UserProfile> getProfile() async {
    final db = await _dbHelper.database;
    final maps = await db.query('perfil', where: 'id = ?', whereArgs: [1]);

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
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

    await db.insert('perfil', defaultProfile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Inicializar también un marcador de lectura por defecto (Juan 1:1 o Juan 5:21)
    await saveBookmark(Bookmark(
      perfilId: 1,
      libroId: 43, // Juan
      capitulo: 5,
      versiculo: 21,
      modo: 'continuo',
      fechaActualizacion: DateTime.now(),
    ));

    // Guardar un pasaje de bienvenida representativo (Jn 3:16)
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
    await db.update(
      'perfil',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== MARCADOR DE LECTURA CONTINUA ====================

  Future<Bookmark?> getBookmark() async {
    final db = await _dbHelper.database;
    final maps = await db.query('marcador_lectura', where: 'perfil_id = ?', whereArgs: [1]);
    if (maps.isEmpty) return null;

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

  Future<void> saveBookmark(Bookmark bookmark) async {
    final db = await _dbHelper.database;
    await db.insert(
      'marcador_lectura',
      bookmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== PASAJES GUARDADOS ====================

  Future<List<SavedPassage>> getSavedPassages({String? etiqueta}) async {
    final db = await _dbHelper.database;
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

    return maps.map((m) => SavedPassage.fromMap(m)).toList();
  }

  Future<int> savePassage(SavedPassage passage) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'pasajes_guardados',
      passage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSavedPassage(int id) async {
    final db = await _dbHelper.database;
    await db.delete('pasajes_guardados', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== HISTORIAL Y ESTADÍSTICAS ====================

  Future<void> logReading({
    required int libroId,
    required int capitulo,
    int? versiculoInicio,
    int? versiculoFin,
  }) async {
    final db = await _dbHelper.database;
    await db.insert('historial_lectura', {
      'perfil_id': 1,
      'libro_id': libroId,
      'capitulo': capitulo,
      'versiculo_inicio': versiculoInicio,
      'versiculo_fin': versiculoFin,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ReadingHistory>> getReadingHistory({int limit = 30}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'historial_lectura',
      where: 'perfil_id = ?',
      whereArgs: [1],
      orderBy: 'fecha DESC',
      limit: limit,
    );

    return maps.map((m) {
      final libroId = m['libro_id'] as int;
      final book = BibleInitialData.books.firstWhere(
        (b) => b.id == libroId,
        orElse: () => BibleInitialData.books.first,
      );
      return ReadingHistory.fromMap(m, libroNombre: book.nombre);
    }).toList();
  }

  /// Calcula estadísticas: Racha de días consecutivos, capítulos leídos, pasajes guardados y notas
  Future<Map<String, dynamic>> getReadingStats() async {
    final db = await _dbHelper.database;

    // Pasajes guardados
    final pasajesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pasajes_guardados WHERE perfil_id = 1'),
    ) ?? 0;

    // Notas y subrayados
    final notasCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM notas WHERE perfil_id = 1'),
    ) ?? 0;
    final highlightsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM subrayados WHERE perfil_id = 1'),
    ) ?? 0;

    // Capítulos leídos únicos
    final capitulosCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(DISTINCT libro_id || "-" || capitulo) FROM historial_lectura WHERE perfil_id = 1'),
    ) ?? 1;

    // Días consecutivos (racha)
    final datesResult = await db.rawQuery('''
      SELECT DISTINCT substr(fecha, 1, 10) as dia 
      FROM historial_lectura 
      WHERE perfil_id = 1 
      ORDER BY dia DESC
    ''');

    int racha = 0;
    if (datesResult.isNotEmpty) {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final yesterdayStr = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      
      final firstDay = datesResult.first['dia'] as String;
      if (firstDay == todayStr || firstDay == yesterdayStr) {
        DateTime cursor = DateTime.parse(firstDay);
        racha = 1;
        for (int i = 1; i < datesResult.length; i++) {
          final nextDay = DateTime.parse(datesResult[i]['dia'] as String);
          if (cursor.difference(nextDay).inDays == 1) {
            racha++;
            cursor = nextDay;
          } else {
            break;
          }
        }
      }
    } else {
      racha = 1; // Primer día de bienvenida
    }

    return {
      'rachaDias': racha > 0 ? racha : 1,
      'capitulosLeidos': capitulosCount > 0 ? capitulosCount : 1,
      'pasajesGuardados': pasajesCount,
      'anotaciones': notasCount + highlightsCount,
    };
  }

  // ==================== SUBRAYADOS Y NOTAS ====================

  Future<void> addHighlight(int versiculoId, String color) async {
    final db = await _dbHelper.database;
    await db.insert('subrayados', {
      'perfil_id': 1,
      'versiculo_id': versiculoId,
      'color': color,
      'fecha_creacion': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserHighlight>> getHighlightsForChapter(int libroId, int capitulo) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT s.*, v.texto AS versiculo_texto, l.abreviatura || ' ' || v.capitulo || ':' || v.numero AS referencia
      FROM subrayados s
      JOIN versiculos v ON s.versiculo_id = v.id
      JOIN libros l ON v.libro_id = l.id
      WHERE s.perfil_id = 1 AND v.libro_id = ? AND v.capitulo = ?
    ''', [libroId, capitulo]);

    return maps.map((m) => UserHighlight.fromMap(m)).toList();
  }

  Future<void> addNote(int versiculoId, String contenido) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.insert('notas', {
      'perfil_id': 1,
      'versiculo_id': versiculoId,
      'contenido': contenido,
      'fecha_creacion': now,
      'fecha_modificacion': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserNote>> getAllNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT n.*, v.texto AS versiculo_texto, l.nombre || ' ' || v.capitulo || ':' || v.numero AS referencia
      FROM notas n
      JOIN versiculos v ON n.versiculo_id = v.id
      JOIN libros l ON v.libro_id = l.id
      WHERE n.perfil_id = 1
      ORDER BY n.fecha_modificacion DESC
    ''');

    return maps.map((m) => UserNote.fromMap(m)).toList();
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
