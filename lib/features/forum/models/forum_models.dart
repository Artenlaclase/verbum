class ForumTopic {
  final String id;
  final String titulo;
  final String contenido;
  final String autorUid;
  final String autorNombre;
  final String autorAvatar;
  final String categoria;
  final DateTime fechaCreacion;
  final int respuestasCount;
  final List<String> likes;

  const ForumTopic({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.autorUid,
    required this.autorNombre,
    required this.autorAvatar,
    required this.categoria,
    required this.fechaCreacion,
    this.respuestasCount = 0,
    this.likes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'contenido': contenido,
      'autor_uid': autorUid,
      'autor_nombre': autorNombre,
      'autor_avatar': autorAvatar,
      'categoria': categoria,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'respuestas_count': respuestasCount,
      'likes': likes,
    };
  }

  factory ForumTopic.fromMap(String id, Map<String, dynamic> map) {
    DateTime fecha;
    try {
      fecha = DateTime.parse(map['fecha_creacion'] as String);
    } catch (_) {
      fecha = DateTime.now();
    }

    return ForumTopic(
      id: id,
      titulo: map['titulo'] as String? ?? 'Sin título',
      contenido: map['contenido'] as String? ?? '',
      autorUid: map['autor_uid'] as String? ?? '',
      autorNombre: map['autor_nombre'] as String? ?? 'Hermano en Cristo',
      autorAvatar: map['autor_avatar'] as String? ?? '✝️',
      categoria: map['categoria'] as String? ?? 'General',
      fechaCreacion: fecha,
      respuestasCount: (map['respuestas_count'] as int?) ?? 0,
      likes: List<String>.from(map['likes'] as List? ?? []),
    );
  }
}

class ForumReply {
  final String id;
  final String topicId;
  final String contenido;
  final String autorUid;
  final String autorNombre;
  final String autorAvatar;
  final DateTime fechaCreacion;

  const ForumReply({
    required this.id,
    required this.topicId,
    required this.contenido,
    required this.autorUid,
    required this.autorNombre,
    required this.autorAvatar,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic_id': topicId,
      'contenido': contenido,
      'autor_uid': autorUid,
      'autor_nombre': autorNombre,
      'autor_avatar': autorAvatar,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  factory ForumReply.fromMap(String id, Map<String, dynamic> map) {
    DateTime fecha;
    try {
      fecha = DateTime.parse(map['fecha_creacion'] as String);
    } catch (_) {
      fecha = DateTime.now();
    }

    return ForumReply(
      id: id,
      topicId: map['topic_id'] as String? ?? '',
      contenido: map['contenido'] as String? ?? '',
      autorUid: map['autor_uid'] as String? ?? '',
      autorNombre: map['autor_nombre'] as String? ?? 'Hermano en Cristo',
      autorAvatar: map['autor_avatar'] as String? ?? '✝️',
      fechaCreacion: fecha,
    );
  }
}

