import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/profile/models/bookmark.dart';
import '../../features/profile/models/reading_history.dart';
import '../../features/profile/models/saved_passage.dart';
import '../../features/profile/models/user_annotation.dart';
import '../../features/profile/models/user_profile.dart';
import '../../features/bible/data/bible_initial_data.dart';
import 'auth_service.dart';

/// Servicio de sincronización con Firestore.
/// Cada usuario tiene su propia colección: users/{uid}/...
class FirestoreSyncService {
  static final FirestoreSyncService instance = FirestoreSyncService._();
  FirestoreSyncService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Duration _timeout = Duration(seconds: 4);

  String? get _uid => AuthService.instance.uid;
  bool get _hasUser => _uid != null;

  DocumentReference<Map<String, dynamic>> _userDoc() =>
      _db.collection('users').doc(_uid!);

  // ==================== PERFIL ====================

  Future<UserProfile?> getProfile() async {
    if (!_hasUser) return null;
    try {
      final doc = await _userDoc()
          .collection('data')
          .doc('profile')
          .get()
          .timeout(_timeout);
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('FirestoreSyncService getProfile: $e');
    }
    return null;
  }

  Future<void> saveProfile(UserProfile profile) async {
    if (!_hasUser) return;
    try {
      final user = AuthService.instance.currentUser;
      final email = user?.email;
      final nowIso = DateTime.now().toIso8601String();

      // Guardar metadatos visibles directamente en el documento raíz users/{uid}
      await _userDoc().set(
        {
          'uid': _uid,
          if (email != null) 'email': email,
          'nombre': profile.nombre,
          'avatar': profile.avatar,
          'ultima_sincronizacion': nowIso,
        },
        SetOptions(merge: true),
      ).timeout(_timeout);

      // Guardar el perfil completo en users/{uid}/data/profile
      final profileData = {
        ...profile.toMap(),
        if (email != null) 'email': email,
        'uid': _uid,
        'ultima_sincronizacion': nowIso,
      };
      await _userDoc()
          .collection('data')
          .doc('profile')
          .set(
            profileData,
            SetOptions(merge: true),
          )
          .timeout(_timeout);
    } catch (e) {
      debugPrint('FirestoreSyncService saveProfile: $e');
    }
  }

  // ==================== MARCADOR ====================

  Future<Bookmark?> getBookmark() async {
    if (!_hasUser) return null;
    try {
      final doc = await _userDoc()
          .collection('data')
          .doc('bookmark')
          .get()
          .timeout(_timeout);
      if (doc.exists && doc.data() != null) {
        final map = doc.data()!;
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
      debugPrint('FirestoreSyncService getBookmark: $e');
    }
    return null;
  }

  Future<void> saveBookmark(Bookmark bookmark) async {
    if (!_hasUser) return;
    try {
      await _userDoc()
          .collection('data')
          .doc('bookmark')
          .set(
            bookmark.toMap(),
            SetOptions(merge: true),
          )
          .timeout(_timeout);
    } catch (e) {
      debugPrint('FirestoreSyncService saveBookmark: $e');
    }
  }

  // ==================== PASAJES GUARDADOS ====================

  Future<List<SavedPassage>> getSavedPassages({String? etiqueta}) async {
    if (!_hasUser) return [];
    try {
      Query<Map<String, dynamic>> query = _userDoc()
          .collection('passages')
          .orderBy('fecha_guardado', descending: true);

      if (etiqueta != null && etiqueta != 'Todos') {
        query = query.where('etiqueta', isEqualTo: etiqueta);
      }

      final snap = await query.get().timeout(_timeout);
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = int.tryParse(d.id) ?? d.id.hashCode;
        return SavedPassage.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('FirestoreSyncService getSavedPassages: $e');
    }
    return [];
  }

  Future<String> savePassage(SavedPassage passage) async {
    if (!_hasUser) return '';
    try {
      final docRef = await _userDoc()
          .collection('passages')
          .add(passage.toMap())
          .timeout(_timeout);
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreSyncService savePassage: $e');
    }
    return '';
  }

  Future<void> deletePassage(String docId) async {
    if (!_hasUser) return;
    try {
      await _userDoc()
          .collection('passages')
          .doc(docId)
          .delete()
          .timeout(_timeout);
    } catch (e) {
      debugPrint('FirestoreSyncService deletePassage: $e');
    }
  }

  // ==================== HISTORIAL ====================

  Future<void> logReading(Map<String, dynamic> logMap) async {
    if (!_hasUser) return;
    try {
      final col = _userDoc().collection('history');
      await col.add(logMap).timeout(_timeout);

      // Mantener máximo 50 registros
      final allDocs = await col
          .orderBy('fecha', descending: true)
          .get()
          .timeout(_timeout);
      if (allDocs.docs.length > 50) {
        final toDelete = allDocs.docs.sublist(50);
        for (final doc in toDelete) {
          await doc.reference.delete().timeout(_timeout);
        }
      }
    } catch (e) {
      debugPrint('FirestoreSyncService logReading: $e');
    }
  }

  Future<List<ReadingHistory>> getReadingHistory({int limit = 30}) async {
    if (!_hasUser) return [];
    try {
      final snap = await _userDoc()
          .collection('history')
          .orderBy('fecha', descending: true)
          .limit(limit)
          .get()
          .timeout(_timeout);

      return snap.docs.map((d) {
        final m = d.data();
        final libroId = m['libro_id'] as int;
        final book = BibleInitialData.books.firstWhere(
          (b) => b.id == libroId,
          orElse: () => BibleInitialData.books.first,
        );
        return ReadingHistory.fromMap(m, libroNombre: book.nombre);
      }).toList();
    } catch (e) {
      debugPrint('FirestoreSyncService getReadingHistory: $e');
    }
    return [];
  }

  // ==================== SUBRAYADOS ====================

  Future<void> addHighlight(Map<String, dynamic> hlMap) async {
    if (!_hasUser) return;
    try {
      await _userDoc().collection('highlights').add(hlMap).timeout(_timeout);
    } catch (e) {
      debugPrint('FirestoreSyncService addHighlight: $e');
    }
  }

  // ==================== NOTAS ====================

  Future<void> addNote(Map<String, dynamic> noteMap) async {
    if (!_hasUser) return;
    try {
      await _userDoc().collection('notes').add(noteMap).timeout(_timeout);
    } catch (e) {
      debugPrint('FirestoreSyncService addNote: $e');
    }
  }

  Future<int> getAnnotationsCount() async {
    if (!_hasUser) return 0;
    try {
      final notesSnap = await _userDoc().collection('notes').get().timeout(_timeout);
      final hlSnap = await _userDoc().collection('highlights').get().timeout(_timeout);
      return notesSnap.docs.length + hlSnap.docs.length;
    } catch (e) {
      debugPrint('FirestoreSyncService getAnnotationsCount: $e');
      return 0;
    }
  }

  // ==================== INTERESADOS EN «CUSTODIO DE LA PALABRA» ====================

  /// Registra el correo y datos de la sesión que hizo clic en «Unirme como Custodio de la Palabra»
  /// para poder contactarlos cuando la función esté habilitada.
  Future<void> registerCustodioInterest({
    String? emailOverride,
    String? nombreOverride,
  }) async {
    final user = AuthService.instance.currentUser;
    final email = emailOverride ?? user?.email ?? 'sin_correo';
    final nombre = nombreOverride ?? user?.displayName ?? 'Usuario Verbum';
    final nowIso = DateTime.now().toIso8601String();

    final payload = {
      'uid': _uid ?? 'invitado',
      'email': email,
      'nombre': nombre,
      'interesado_custodio': true,
      'fecha_clic_custodio': nowIso,
    };

    if (_hasUser) {
      try {
        // 1. Guardar directamente en el documento raíz users/{uid} (cubierto por las reglas actuales)
        await _userDoc()
            .set(payload, SetOptions(merge: true))
            .timeout(_timeout);

        // 2. Guardar detalle en users/{uid}/data/custodio_waitlist
        await _userDoc()
            .collection('data')
            .doc('custodio_waitlist')
            .set(payload, SetOptions(merge: true))
            .timeout(_timeout);
      } catch (e) {
        debugPrint('FirestoreSyncService registerCustodioInterest userDoc: $e');
      }
    }

    try {
      // 3. Guardar también en colección general custodio_interesados (si las reglas lo permiten)
      final docId = _uid ?? email.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      await _db
          .collection('custodio_interesados')
          .doc(docId)
          .set(payload, SetOptions(merge: true))
          .timeout(_timeout);
    } catch (_) {}
  }

  // ==================== MIGRACIÓN LOCAL → FIRESTORE ====================

  /// Migra todos los datos locales (SharedPreferences) a Firestore.
  /// Se llama al primer login exitoso.
  Future<void> migrateLocalToFirestore() async {
    if (!_hasUser) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Perfil y metadatos de cuenta (email, uid)
      final profileJson = prefs.getString('verbum_profile');
      if (profileJson != null) {
        try {
          final map = jsonDecode(profileJson) as Map<String, dynamic>;
          final profile = UserProfile.fromMap(map);
          final existing = await getProfile();
          await saveProfile(existing ?? profile);
        } catch (_) {}
      } else {
        final existing = await getProfile();
        if (existing != null) {
          await saveProfile(existing);
        }
      }

      // 2. Marcador
      final bmJson = prefs.getString('verbum_bookmark');
      if (bmJson != null) {
        try {
          final map = jsonDecode(bmJson) as Map<String, dynamic>;
          final bookmark = Bookmark.fromMap(map);
          final existing = await getBookmark();
          if (existing == null) {
            await saveBookmark(bookmark);
          }
        } catch (_) {}
      }

      // 3. Pasajes guardados
      final passagesList = prefs.getStringList('verbum_saved_passages') ?? [];
      if (passagesList.isNotEmpty) {
        final existingPassages = await getSavedPassages();
        if (existingPassages.isEmpty) {
          for (final pStr in passagesList) {
            try {
              final map = jsonDecode(pStr) as Map<String, dynamic>;
              final passage = SavedPassage.fromMap(map);
              await savePassage(passage);
            } catch (_) {}
          }
        }
      }

      // 4. Historial
      final historyList = prefs.getStringList('verbum_history') ?? [];
      if (historyList.isNotEmpty) {
        final existingHistory = await getReadingHistory();
        if (existingHistory.isEmpty) {
          for (final hStr in historyList) {
            try {
              final map = jsonDecode(hStr) as Map<String, dynamic>;
              await logReading(map);
            } catch (_) {}
          }
        }
      }

      // 5. Subrayados
      final hlList = prefs.getStringList('verbum_highlights') ?? [];
      if (hlList.isNotEmpty) {
        for (final hlStr in hlList) {
          try {
            final map = jsonDecode(hlStr) as Map<String, dynamic>;
            await addHighlight(map);
          } catch (_) {}
        }
      }

      // 6. Notas
      final notesList = prefs.getStringList('verbum_notes') ?? [];
      if (notesList.isNotEmpty) {
        for (final nStr in notesList) {
          try {
            final map = jsonDecode(nStr) as Map<String, dynamic>;
            await addNote(map);
          } catch (_) {}
        }
      }

      debugPrint('FirestoreSyncService: migración local → Firestore completada');
    } catch (e) {
      debugPrint('FirestoreSyncService migrateLocalToFirestore error: $e');
    }
  }
}
