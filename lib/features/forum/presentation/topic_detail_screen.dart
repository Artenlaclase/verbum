import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/forum_repository.dart';
import '../models/forum_models.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final ForumTopic topic;

  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply(String autorNombre, String autorAvatar) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await ForumRepository.instance.addReply(
        topicId: widget.topic.id,
        contenido: text,
        autorNombre: autorNombre,
        autorAvatar: autorAvatar,
      );
      _replyController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuesta enviada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al responder: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUid = AuthService.instance.uid;
    final profile = ref.watch(userProfileProvider).asData?.value;
    final autorNombre = profile?.nombre ?? 'Lector Verbum';
    final autorAvatar = profile?.avatar ?? '✝️';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema'),
        actions: [
          if (currentUid != null && currentUid == widget.topic.autorUid)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              tooltip: 'Eliminar tema',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar tema'),
                    content: const Text('¿Estás seguro de que deseas eliminar este tema? Esta acción no se puede deshacer.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ForumRepository.instance.deleteTopic(widget.topic.id, widget.topic.autorUid);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tema eliminado')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Mensaje principal y respuestas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Tarjeta del tema principal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2128) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGold.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.15),
                            child: Text(widget.topic.autorAvatar, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.topic.autorNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(
                                  '${widget.topic.fechaCreacion.day}/${widget.topic.fechaCreacion.month}/${widget.topic.fechaCreacion.year} ${widget.topic.fechaCreacion.hour}:${widget.topic.fechaCreacion.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.topic.categoria,
                              style: const TextStyle(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.topic.titulo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.topic.contenido,
                        style: TextStyle(fontSize: 14.5, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              currentUid != null && widget.topic.likes.contains(currentUid)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => ForumRepository.instance.toggleLike(widget.topic.id),
                          ),
                          Text('${widget.topic.likes.length} bendiciones', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Respuestas y Comentarios',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Stream de respuestas
                StreamBuilder<List<ForumReply>>(
                  stream: ForumRepository.instance.getRepliesStream(widget.topic.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                    }

                    final replies = snapshot.data ?? [];

                    if (replies.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'Aún no hay respuestas en este tema.\n¡Escribe la primera abajo!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 13),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: replies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final reply = replies[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF191B20) : const Color(0xFFFBF8F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.15),
                                    child: Text(reply.autorAvatar, style: const TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    reply.autorNombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${reply.fechaCreacion.day}/${reply.fechaCreacion.month} ${reply.fechaCreacion.hour}:${reply.fechaCreacion.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                reply.contenido,
                                style: TextStyle(fontSize: 13.5, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Barra inferior para redactar respuesta
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16181D) : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu respuesta con amor fraterno...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded, color: AppTheme.primaryGold),
                  onPressed: _isSending ? null : () => _sendReply(autorNombre, autorAvatar),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

