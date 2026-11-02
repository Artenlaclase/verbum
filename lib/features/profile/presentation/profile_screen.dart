import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_sync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/liturgical_colors.dart';
import '../../auth/presentation/auth_screen.dart';
import '../models/user_profile.dart';
import 'saved_passages_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(readingStatsProvider);
    final isCustodio = ref.watch(isCustodioProvider);
    final isAuthenticated = ref.watch(authStateProvider).asData?.value != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final avatarEmojis = ['✝️', '🕊️', '📖', '🕯️', '⛪', '🌾', '🐟', '👑'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver a Inicio',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              ref.read(homeTabIndexProvider.notifier).setTab(0);
            }
          },
        ),
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
            const SizedBox(height: 20),

            // BOTÓN SIMPLE DE INICIO / CIERRE DE SESIÓN
            _buildSessionButton(context, ref),
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
                    subtitle: Text(
                      isAuthenticated
                          ? 'Textos favoritos con etiquetas temáticas'
                          : 'Inicia sesión para guardar tus pasajes favoritos',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (!isAuthenticated) {
                        _promptSignInForFeature(
                          context,
                          ref,
                          'Para guardar y consultar tus pasajes favoritos necesitas iniciar sesión.',
                        );
                        return;
                      }
                      ref.read(homeTabIndexProvider.notifier).setTab(3);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history_rounded, color: LiturgicalColors.verde),
                    title: const Text('Historial de Lectura', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      isAuthenticated
                          ? 'Registro cronológico de tus lecturas'
                          : 'Inicia sesión para registrar tu historial de lectura',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (!isAuthenticated) {
                        _promptSignInForFeature(
                          context,
                          ref,
                          'Para llevar un historial de lectura y estadísticas necesitas iniciar sesión.',
                        );
                        return;
                      }
                      _showHistoryModal(context, ref);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ALIANZA DE SOSTENIMIENTO: «CUSTODIO DE LA PALABRA» vs «CAMINO ABIERTO»
            _buildCustodioAllianceCard(
              context: context,
              ref: ref,
              isCustodio: isCustodio,
              profile: profileAsync.asData?.value,
              stats: statsAsync.asData?.value,
            ),
            const SizedBox(height: 24),

            // PREFERENCIAS Y SISTEMA (Solo visible cuando es Custodio de la Palabra)
            if (isCustodio) ...[
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.primaryGold),
                  const SizedBox(width: 8),
                  const Text(
                    'Ajustes del Scriptorium',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryGold),
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
                      title: const Text('Exportar Relicario (JSON)'),
                      subtitle: const Text('Copia de seguridad local sin servidor'),
                      onTap: () => _exportProfile(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.file_download_outlined, color: LiturgicalColors.morado),
                      title: const Text('Importar Relicario (JSON)'),
                      subtitle: const Text('Restaurar datos desde archivo o texto'),
                      onTap: () => _importProfile(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

          ],
        ),
      ),
    );
  }

  Widget _buildSessionButton(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;

    if (user != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.45)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text(
            'Cerrar Sesión',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onPressed: () => _confirmSignOut(context, ref),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGold,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.login_rounded, size: 18),
        label: const Text(
          'Iniciar Sesión',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: () async {
          final success = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
          if (success == true && context.mounted) {
            ref.invalidate(userProfileProvider);
            ref.invalidate(bookmarkProvider);
            ref.invalidate(savedPassagesProvider);
            ref.invalidate(readingStatsProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Sesión iniciada correctamente!')),
            );
          }
        },
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

  Future<void> _promptSignInForFeature(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) async {
    final goLogin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lock_person_rounded, color: AppTheme.primaryGold),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Inicia sesión en Verbum',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Iniciar Sesión / Crear Cuenta',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (goLogin == true && context.mounted) {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (success == true && context.mounted) {
        ref.invalidate(userProfileProvider);
        ref.invalidate(bookmarkProvider);
        ref.invalidate(savedPassagesProvider);
        ref.invalidate(readingStatsProvider);
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Deseas cerrar tu sesión? La aplicación volverá a cero en este dispositivo, pero tus datos seguirán resguardados en tu cuenta en la nube.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(profileRepositoryProvider).clearLocalUserData();
      await AuthService.instance.signOut();
      ref.invalidate(userProfileProvider);
      ref.invalidate(bookmarkProvider);
      ref.invalidate(savedPassagesProvider);
      ref.invalidate(readingStatsProvider);
      // Regresar automáticamente a Inicio (pestaña 0) al cerrar sesión
      ref.read(homeTabIndexProvider.notifier).setTab(0);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada. La aplicación ha vuelto a cero.')),
        );
      }
    }
  }

  Widget _buildCustodioAllianceCard({
    required BuildContext context,
    required WidgetRef ref,
    required bool isCustodio,
    required UserProfile? profile,
    required Map<String, dynamic>? stats,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedCount = (stats?['pasajesGuardados'] as int?) ?? 0;
    final notesCount = (stats?['anotaciones'] as int?) ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF231F16),
                  const Color(0xFF17191F),
                ]
              : [
                  const Color(0xFFFFF8E5),
                  const Color(0xFFFFFFFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGold.withValues(alpha: isCustodio ? 0.65 : 0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppTheme.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Custodio de la Palabra',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCustodio
                                ? LiturgicalColors.verde.withValues(alpha: 0.18)
                                : AppTheme.primaryGold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isCustodio ? 'ACTIVO' : 'CAMINO ABIERTO',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isCustodio ? LiturgicalColors.verde : AppTheme.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCustodio
                          ? 'Gracias por sostener esta obra de difusión bíblica.'
                          : 'Alianza espiritual para sostener Verbum y ampliar tu estudio.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!isCustodio) ...[
            // Indicadores de uso en «Camino Abierto» (Gratis)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF6F1E3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu capacidad actual en Camino Abierto (Gratis):',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('• Relicario de Pasajes Guardados', style: TextStyle(fontSize: 12)),
                      Text(
                        '$savedCount / ${VerbumPlanLimits.maxFreePassages} máx.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('• Notas y Subrayados de Estudio', style: TextStyle(fontSize: 12)),
                      Text(
                        '$notesCount / ${VerbumPlanLimits.maxFreeAnnotations} máx.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildAllianceFeatureRow(
              Icons.all_inclusive_rounded,
              'Relicario y Cuaderno sin límites (pasajes, notas y etiquetas infinitas)',
            ),
            const SizedBox(height: 6),
            _buildAllianceFeatureRow(
              Icons.palette_outlined,
              'Desbloquea los Ajustes del Scriptorium (Temas Pergamino/Carbón y Copias JSON)',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text(
                  'Unirme como Custodio de la Palabra',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showCustodioModal(context, ref, profile, false),
              ),
            ),
          ] else ...[
            _buildAllianceFeatureRow(
              Icons.check_circle_outline_rounded,
              'Relicario ilimitado y Ajustes del Scriptorium desbloqueados abajo.',
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showCustodioModal(context, ref, profile, true),
                child: const Text(
                  'Gestionar mi Alianza de Custodio',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryGold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllianceFeatureRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, height: 1.35),
          ),
        ),
      ],
    );
  }

  void _showCustodioModal(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
    bool currentlyCustodio,
  ) async {
    final user = AuthService.instance.currentUser;

    // Si el usuario tiene sesión iniciada, registrar de inmediato su correo en Firestore
    if (user != null) {
      await FirestoreSyncService.instance.registerCustodioInterest(
        emailOverride: user.email,
        nombreOverride: profile?.nombre ?? user.displayName,
      );
    }

    if (!context.mounted) return;

    final guestEmailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryGold),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Custodio de la Palabra',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notifications_active_rounded, color: AppTheme.primaryGold, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Esta función aún no está habilitada, pero te avisaremos en cuanto se pueda.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (user != null && user.email != null) ...[
                Text(
                  'Hemos registrado el correo de tu sesión (${user.email}) en nuestra lista prioritaria para contactarte apenas esté disponible.',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ] else ...[
                const Text(
                  'Déjanos tu correo electrónico (o inicia sesión) para avisarte apenas esté disponible:',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: guestEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Tu correo electrónico',
                    hintText: 'ejemplo@correo.com',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (user == null)
              TextButton(
                onPressed: () async {
                  final email = guestEmailController.text.trim();
                  if (email.isNotEmpty && email.contains('@')) {
                    await FirestoreSyncService.instance.registerCustodioInterest(
                      emailOverride: email,
                      nombreOverride: profile?.nombre,
                    );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Gracias! Te avisaremos en cuanto esté habilitada.'),
                      ),
                    );
                  }
                },
                child: const Text('Guardar mi correo'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Entendido',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
