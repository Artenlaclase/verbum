import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../models/forum_models.dart';

class ForumRepository {
  static final ForumRepository instance = ForumRepository._();
  ForumRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _topicsCollection =>
      _db.collection('forum_topics');

  /// Stream de todos los temas ordenados por fecha de creación descendente
  Stream<List<ForumTopic>> getTopicsStream({String? categoria}) {
    Query<Map<String, dynamic>> query = _topicsCollection;

    if (categoria != null && categoria != 'Todos') {
      query = query.where('categoria', isEqualTo: categoria);
    } else {
      query = query.orderBy('fecha_creacion', descending: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ForumTopic.fromMap(doc.id, doc.data()))
          .toList();
      // Ordenamiento en memoria para no requerir índice compuesto en Firestore
      list.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return list;
    });
  }

  /// Crear un nuevo tema
  Future<String> createTopic({
    required String titulo,
    required String contenido,
    required String categoria,
    required String autorNombre,
    required String autorAvatar,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para publicar en el foro.');
    }

    final topic = ForumTopic(
      id: '',
      titulo: titulo,
      contenido: contenido,
      autorUid: user.uid,
      autorNombre: autorNombre.trim().isNotEmpty ? autorNombre : (user.displayName ?? 'Lector Verbum'),
      autorAvatar: autorAvatar,
      categoria: categoria,
      fechaCreacion: DateTime.now(),
      respuestasCount: 0,
      likes: [],
    );

    final docRef = await _topicsCollection.add(topic.toMap());
    return docRef.id;
  }

  /// Alternar bendición / me gusta en un tema
  Future<void> toggleLike(String topicId) async {
    final uid = AuthService.instance.uid;
    if (uid == null) return;

    final docRef = _topicsCollection.doc(topicId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final likes = List<String>.from(snap.data()?['likes'] as List? ?? []);
    if (likes.contains(uid)) {
      likes.remove(uid);
    } else {
      likes.add(uid);
    }

    await docRef.update({'likes': likes});
  }

  /// Obtener stream de respuestas de un tema específico
  Stream<List<ForumReply>> getRepliesStream(String topicId) {
    return _topicsCollection
        .doc(topicId)
        .collection('replies')
        .orderBy('fecha_creacion', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ForumReply.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Añadir una respuesta a un tema
  Future<void> addReply({
    required String topicId,
    required String contenido,
    required String autorNombre,
    required String autorAvatar,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para responder.');
    }

    final reply = ForumReply(
      id: '',
      topicId: topicId,
      contenido: contenido,
      autorUid: user.uid,
      autorNombre: autorNombre.trim().isNotEmpty ? autorNombre : (user.displayName ?? 'Lector Verbum'),
      autorAvatar: autorAvatar,
      fechaCreacion: DateTime.now(),
    );

    final repliesCol = _topicsCollection.doc(topicId).collection('replies');
    await repliesCol.add(reply.toMap());

    // Incrementar contador de respuestas
    await _topicsCollection.doc(topicId).update({
      'respuestas_count': FieldValue.increment(1),
    });
  }

  /// Eliminar un tema propio
  Future<void> deleteTopic(String topicId, String autorUid) async {
    final user = AuthService.instance.currentUser;
    if (user == null || user.uid != autorUid) {
      throw Exception('No tienes permiso para eliminar este tema.');
    }
    await _topicsCollection.doc(topicId).delete();
  }
}

