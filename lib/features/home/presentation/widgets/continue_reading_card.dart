import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/models/bookmark.dart';

class ContinueReadingCard extends StatelessWidget {
  final Bookmark? bookmark;
  final VoidCallback onTap;

  const ContinueReadingCard({
    super.key,
    required this.bookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final ref = bookmark?.referencia ?? 'San Juan 1:1';
    final bookName = bookmark?.libroNombre ?? 'Evangelio según San Juan';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23252A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGold.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono destacado de marcador
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.bookmark_added_rounded,
                color: AppTheme.primaryGold,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Textos del marcador
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'MODO CORRIDO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Última lectura',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Continuar en $ref',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bookName,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Flecha de acción
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.primaryGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
