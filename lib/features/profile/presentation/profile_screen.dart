import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/liturgical_colors.dart';
import '../models/user_profile.dart';
import 'saved_passages_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(readingStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final avatarEmojis = ['✝️', '🕊️', '📖', '🕯️', '⛪', '🌾', '🐟', '👑'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Devocional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO DEL PERFIL
            profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (profile) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGold.withOpacity(0.18),
                        LiturgicalColors.verde.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      // Avatar táctil para cambiar emoji
                      InkWell(
                        onTap: () => _showAvatarPicker(context, ref, profile, avatarEmojis),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isDark ? 0.1 : 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryGold, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(profile.avatar, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Datos de usuario
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  profile.nombre,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () => _showEditNameDialog(context, ref, profile),
                                ),
                              ],
                            ),
                            Text(
                              'En Verbum desde ${profile.fechaCreacion.day}/${profile.fechaCreacion.month}/${profile.fechaCreacion.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: LiturgicalColors.verde.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Biblia Reina-Valera 1909 (Dominio Público)',
                                style: TextStyle(fontSize: 10, color: LiturgicalColors.verde, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ESTADÍSTICAS EN TIEMPO REAL
            const Text(
              'Estadísticas de Lectura',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
              data: (stats) {
                return Row(
                  children: [
                    _buildStatCard(
                      context: context,
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.deepOrange,
                      value: '${stats["rachaDias"]}',
                      label: 'Días Racha',
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      context: context,
                      icon: Icons.auto_stories_rounded,
                      color: LiturgicalColors.verde,
                      value: '${stats["capitulosLeidos"]}',
                      label: 'Capítulos',
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      context: context,
                      icon: Icons.bookmark_added_rounded,
                      color: AppTheme.primaryGold,
                      value: '${stats["pasajesGuardados"]}',
                      label: 'Guardados',
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      context: context,
                      icon: Icons.edit_note_rounded,
                      color: LiturgicalColors.morado,
                      value: '${stats["anotaciones"]}',
                      label: 'Notas/Subr.',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ACCESOS RÁPIDOS DEL PERFIL
            const Text(
              'Mi Estudio Personal',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.bookmark_added_rounded, color: AppTheme.primaryGold),
                    title: const Text('Mis Pasajes Guardados', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Textos favoritos con etiquetas temáticas'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedPassagesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history_rounded, color: LiturgicalColors.verde),
                    title: const Text('Historial de Lectura', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Registro cronológico de tus lecturas'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showHistoryModal(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PREFERENCIAS Y SISTEMA
            const Text(
              'Ajustes de la Aplicación',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Tema visual'),
                    trailing: DropdownButton<ThemeMode>(
                      value: ref.watch(themeModeStateProvider),
                      underline: const SizedBox(),
                      onChanged: (mode) {
                        if (mode != null) {
                          ref.read(themeModeStateProvider.notifier).setThemeMode(mode);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: ThemeMode.system, child: Text('Sistema')),
                        DropdownMenuItem(value: ThemeMode.light, child: Text('Claro (Pergamino)')),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro (Carbón)')),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_upload_outlined, color: AppTheme.primaryGold),
                    title: const Text('Exportar Perfil (JSON)'),
                    subtitle: const Text('Copia de seguridad local sin servidor'),
                    onTap: () => _exportProfile(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined, color: LiturgicalColors.morado),
                    title: const Text('Importar Perfil (JSON)'),
                    subtitle: const Text('Restaurar datos desde archivo o texto'),
                    onTap: () => _importProfile(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2024) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref, UserProfile profile, List<String> avatars) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Elige tu símbolo de devoción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: avatars.map((a) {
                  return InkWell(
                    onTap: () async {
                      final updated = profile.copyWith(avatar: a);
                      await ref.read(profileRepositoryProvider).updateProfile(updated);
                      ref.invalidate(userProfileProvider);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(a, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final controller = TextEditingController(text: profile.nombre);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Nombre'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Tu nombre', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  final updated = profile.copyWith(nombre: controller.text.trim());
                  await ref.read(profileRepositoryProvider).updateProfile(updated);
                  ref.invalidate(userProfileProvider);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryModal(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(profileRepositoryProvider);
    final history = await repo.getReadingHistory();

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Historial de Lectura', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: history.isEmpty
                        ? const Center(child: Text('Sin lecturas registradas aún'))
                        : ListView.builder(
                            controller: controller,
                            itemCount: history.length,
                            itemBuilder: (_, idx) {
                              final h = history[idx];
                              return ListTile(
                                leading: const Icon(Icons.bookmark_border_rounded, color: AppTheme.primaryGold),
                                title: Text('${h.libroNombre ?? "Libro"} ${h.capitulo}'),
                                subtitle: Text(
                                  'Leído el ${h.fecha.day}/${h.fecha.month}/${h.fecha.year} a las ${h.fecha.hour}:${h.fecha.minute.toString().padLeft(2, '0')}',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportProfile(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(profileRepositoryProvider);
    final jsonStr = await repo.exportBackupJson();

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Copia de Seguridad JSON'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tus datos están listos para ser respaldados o migrados sin necesidad de servidor.'),
              const SizedBox(height: 10),
              Container(
                height: 150,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(jsonStr, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copiar JSON'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copia de seguridad JSON copiada al portapapeles')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _importProfile(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Restaurar Perfil JSON'),
          content: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Pega aquí el contenido JSON exportado...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(profileRepositoryProvider);
                final ok = await repo.importBackupJson(controller.text.trim());
                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (ok) {
                    ref.invalidate(userProfileProvider);
                    ref.invalidate(bookmarkProvider);
                    ref.invalidate(savedPassagesProvider);
                    ref.invalidate(readingStatsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil restaurado exitosamente')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al procesar el formato JSON')),
                    );
                  }
                }
              },
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );
  }
}
