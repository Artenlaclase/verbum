import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../bible/presentation/search_screen.dart';


class SavedPassagesScreen extends ConsumerWidget {
  const SavedPassagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passagesAsync = ref.watch(savedPassagesProvider);
    final selectedTag = ref.watch(selectedTagFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tags = ['Todos', 'Fe', 'Oración', 'Consuelo', 'Esperanza', 'Gratitud', 'Amor', 'Paz', 'Sabiduría'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pasajes Guardados'),
      ),
      body: Column(
        children: [
          // Chips de filtro por etiquetas
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = tags[index];
                final isSelected = selectedTag == tag;
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGold.withOpacity(0.2),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryGold : null,
                  ),
                  onSelected: (_) {
                    ref.read(selectedTagFilterProvider.notifier).setTag(tag);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Lista de pasajes
          Expanded(
            child: passagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (passages) {
                if (passages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          selectedTag == 'Todos'
                              ? 'Aún no tienes pasajes guardados'
                              : 'No hay pasajes con etiqueta "$selectedTag"',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Toca cualquier versículo mientras lees para guardarlo aquí.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: passages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final p = passages[index];
                    Color cardBaseColor = AppTheme.primaryGold;
                    try {
                      cardBaseColor = Color(int.parse('0xFF${p.color.replaceAll('#', '')}'));
                    } catch (_) {}

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: cardBaseColor.withOpacity(0.35), width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado del pasaje con etiqueta y acciones
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: cardBaseColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        p.etiqueta,
                                        style: TextStyle(
                                          color: cardBaseColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      p.referenciaCompleta,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, size: 18),
                                      tooltip: 'Copiar',
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                          text: '"${p.textoSnapshot}" (${p.referenciaCompleta} RVR09)',
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Copiado al portapapeles')),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                      tooltip: 'Eliminar',
                                      onPressed: () async {
                                        if (p.id != null) {
                                          final repo = ref.read(profileRepositoryProvider);
                                          await repo.deleteSavedPassage(p.id!);
                                          ref.invalidate(savedPassagesProvider);
                                          ref.invalidate(readingStatsProvider);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (p.titulo != null && p.titulo!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                p.titulo!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],

                            const SizedBox(height: 8),
                            Text(
                              '"${p.textoSnapshot}"',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),

                            if (p.notas != null && p.notas!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF26292E) : const Color(0xFFF0EDE5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Nota: ${p.notas}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SearchScreen(initialQuery: p.referenciaInicio),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.menu_book_rounded, size: 14),
                                label: const Text('Abrir en la Biblia', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
