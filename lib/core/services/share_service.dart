import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../../features/forum/presentation/forum_screen.dart';

class ShareService {
  ShareService._();

  /// Comparte un versículo o pasaje bíblico.
  /// En plataformas web/móvil usa Web Share API si está disponible,
  /// abre el diálogo fraterno con opción de copiar, compartir en redes/WhatsApp y publicar en el Foro Verbum.
  static Future<void> shareVerse({
    required BuildContext context,
    required String reference,
    required String text,
    String version = 'RVR09',
  }) async {
    final shareText = '«$text»\n\n— $reference ($version)\nCompartido desde Verbum: Sagrada Escritura y Liturgia';

    _showShareModal(
      context: context,
      reference: reference,
      text: text,
      fullFormattedText: shareText,
    );
  }

  static void _showShareModal({
    required BuildContext context,
    required String reference,
    required String text,
    required String fullFormattedText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share_rounded, color: AppTheme.primaryGold, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Compartir la Palabra',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Vista previa de la tarjeta devocional
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2128) : const Color(0xFFFBF8F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGold.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reference,
                        style: const TextStyle(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '«$text»',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Opciones de compartir
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 1. Copiar al portapapeles
                    _buildShareAction(
                      context: ctx,
                      icon: Icons.copy_rounded,
                      label: 'Copiar',
                      color: AppTheme.primaryGold,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: fullFormattedText));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pasaje copiado con formato al portapapeles'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                    // 2. Compartir en WhatsApp
                    _buildShareAction(
                      context: ctx,
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () {
                        Navigator.pop(ctx);
                        Clipboard.setData(ClipboardData(text: fullFormattedText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copiado para WhatsApp: pégalo en tu chat favorito'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                    // 3. Compartir en el Foro Verbum
                    _buildShareAction(
                      context: ctx,
                      icon: Icons.forum_rounded,
                      label: 'En el Foro',
                      color: const Color(0xFF2A7B9B),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForumScreen()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Abre un nuevo tema en el Foro para reflexionar sobre $reference'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildShareAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

