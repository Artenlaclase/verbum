import 'package:flutter/material.dart';
import '../../../../core/theme/liturgical_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onOpenBible;
  final VoidCallback onOpenContinuous;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenProfile;

  const QuickActionsGrid({
    super.key,
    required this.onOpenBible,
    required this.onOpenContinuous,
    required this.onOpenCalendar,
    required this.onOpenSaved,
    required this.onOpenSearch,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explorar Verbum',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          children: [
            _buildTile(
              context: context,
              icon: Icons.menu_book_rounded,
              color: LiturgicalColors.verde,
              label: 'Biblia',
              subtitle: '66 Libros',
              onTap: onOpenBible,
            ),
            _buildTile(
              context: context,
              icon: Icons.chrome_reader_mode_rounded,
              color: LiturgicalColors.morado,
              label: 'Modo Corrido',
              subtitle: 'Sin pausas',
              onTap: onOpenContinuous,
            ),
            _buildTile(
              context: context,
              icon: Icons.calendar_month_rounded,
              color: LiturgicalColors.rojo,
              label: 'Calendario',
              subtitle: 'Litúrgico',
              onTap: onOpenCalendar,
            ),
            _buildTile(
              context: context,
              icon: Icons.bookmark_added_rounded,
              color: LiturgicalColors.dorado,
              label: 'Mis Pasajes',
              subtitle: 'Guardados',
              onTap: onOpenSaved,
            ),
            _buildTile(
              context: context,
              icon: Icons.search_rounded,
              color: const Color(0xFF2A7B9B),
              label: 'Búsqueda',
              subtitle: 'Texto y citas',
              onTap: onOpenSearch,
            ),
            _buildTile(
              context: context,
              icon: Icons.person_rounded,
              color: const Color(0xFF7B52AB),
              label: 'Mi Perfil',
              subtitle: 'Racha y datos',
              onTap: onOpenProfile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2024) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
