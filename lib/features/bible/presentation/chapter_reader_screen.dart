import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/liturgical_colors.dart';
import '../../profile/models/saved_passage.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import 'continuous_reader_screen.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
  final BibleBook book;
  final int chapter;

  const ChapterReaderScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  ConsumerState<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  late int _currentChapter;
  List<BibleVerse> _verses = [];
  bool _isLoading = true;
  double _fontSize = 18.0;
  Map<int, String> _highlights = {}; // versiculoId -> hex color

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    setState(() => _isLoading = true);
    final repo = ref.read(bibleRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    final verses = await repo.getVerses(widget.book.id, _currentChapter);
    final hlList = await profileRepo.getHighlightsForChapter(widget.book.id, _currentChapter);
    final hlMap = {for (var h in hlList) h.versiculoId: h.color};

    // Registrar en historial de lectura
    await profileRepo.logReading(
      libroId: widget.book.id,
      capitulo: _currentChapter,
      versiculoInicio: 1,
      versiculoFin: verses.isNotEmpty ? verses.last.numero : 1,
    );

    // Invalidar estadísticas para actualizar racha
    ref.invalidate(readingStatsProvider);

    if (mounted) {
      setState(() {
        _verses = verses;
        _highlights = hlMap;
        _isLoading = false;
      });
    }
  }

  void _nextChapter() {
    if (_currentChapter < widget.book.totalCapitulos) {
      setState(() => _currentChapter++);
      _loadChapter();
    }
  }

  void _prevChapter() {
    if (_currentChapter > 1) {
      setState(() => _currentChapter--);
      _loadChapter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book.nombre} $_currentChapter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            tooltip: 'Ajustar tamaño',
            onPressed: _showFontDialog,
          ),
          IconButton(
            icon: const Icon(Icons.chrome_reader_mode_outlined),
            tooltip: 'Cambiar a Modo Corrido',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ContinuousReaderScreen(
                    initialBookId: widget.book.id,
                    initialChapter: _currentChapter,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: _currentChapter > 1 ? _prevChapter : null,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Capítulo anterior',
            ),
            Text(
              'Capítulo $_currentChapter de ${widget.book.totalCapitulos}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            IconButton.filledTonal(
              onPressed: _currentChapter < widget.book.totalCapitulos ? _nextChapter : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              tooltip: 'Capítulo siguiente',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: _verses.length,
              itemBuilder: (context, index) {
                final verse = _verses[index];
                final highlightColorHex = _highlights[verse.id];

                Color? highlightBg;
                if (highlightColorHex != null) {
                  try {
                    final cleanHex = highlightColorHex.replaceAll('#', '');
                    highlightBg = Color(int.parse('0x55$cleanHex'));
                  } catch (_) {}
                }

                return InkWell(
                  onTap: () => _showVerseContextMenu(verse),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: highlightBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.merriweather(
                          fontSize: _fontSize,
                          height: 1.8,
                          color: isDark ? const Color(0xFFE2DDD5) : const Color(0xFF232323),
                        ),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '${verse.numero}',
                                style: TextStyle(
                                  fontSize: _fontSize * 0.72,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGold,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(text: verse.texto),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showVerseContextMenu(BibleVerse verse) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      verse.referencia,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  '"${verse.texto}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Divider(),

                // Opciones de acción
                ListTile(
                  leading: const Icon(Icons.bookmark_add_rounded, color: AppTheme.primaryGold),
                  title: const Text('Guardar en mi perfil', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Guardar pasaje con etiquetas y notas'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSavePassageDialog(verse);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: LiturgicalColors.verde),
                  title: const Text('Añadir nota personal'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddNoteDialog(verse);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.format_paint_rounded, color: LiturgicalColors.morado),
                  title: const Text('Subrayar versículo'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildColorDot(verse, '#FFF176'), // Amarillo
                      _buildColorDot(verse, '#A5D6A7'), // Verde
                      _buildColorDot(verse, '#90CAF9'), // Azul
                      _buildColorDot(verse, '#F48FB1'), // Rosa
                      _buildColorDot(verse, '#CE93D8'), // Morado
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copiar versículo'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '${verse.texto} (${verse.referencia} RVR09)'));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Versículo copiado al portapapeles')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorDot(BibleVerse verse, String colorHex) {
    return InkWell(
      onTap: () async {
        final profileRepo = ref.read(profileRepositoryProvider);
        await profileRepo.addHighlight(verse.id, colorHex);
        setState(() {
          _highlights[verse.id] = colorHex;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Versículo resaltado')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Color(int.parse('0xFF${colorHex.replaceAll('#', '')}')),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26),
        ),
      ),
    );
  }

  /// Diálogo oficial de "Guardar pasaje en mi perfil" (Especificación Sección 7.3 y 7.4 del PDF)
  void _showSavePassageDialog(BibleVerse verse) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    String selectedTag = 'Fe';
    String selectedColor = '#C9A227';

    final tags = ['Fe', 'Oración', 'Consuelo', 'Esperanza', 'Gratitud', 'Amor', 'Paz', 'Sabiduría'];
    final colors = [
      {'hex': '#C9A227', 'name': 'Dorado'},
      {'hex': '#6A2C8F', 'name': 'Morado'},
      {'hex': '#2E7D32', 'name': 'Verde'},
      {'hex': '#B22234', 'name': 'Rojo'},
      {'hex': '#1E88E5', 'name': 'Azul'},
    ];

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.bookmark_added_rounded, color: AppTheme.primaryGold),
                  const SizedBox(width: 8),
                  const Text('Guardar en mi Perfil'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verse.referencia,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${verse.texto}"',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Título opcional
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título personalizado (opcional)',
                        hintText: 'ej. Confianza en el Señor',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Selector de etiqueta
                    const Text('Etiqueta temática:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((t) {
                        final isSel = selectedTag == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: isSel,
                          onSelected: (_) => setDState(() => selectedTag = t),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Color de la tarjeta
                    const Text('Color de la tarjeta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: colors.map((c) {
                        final hex = c['hex']!;
                        final isSel = selectedColor == hex;
                        return GestureDetector(
                          onTap: () => setDState(() => selectedColor = hex),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(int.parse('0xFF${hex.replaceAll('#', '')}')),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.black : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSel ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Nota rápida opcional
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Nota rápida o reflexión (opcional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final passage = SavedPassage(
                      perfilId: 1,
                      titulo: titleController.text.trim().isNotEmpty ? titleController.text.trim() : null,
                      referenciaInicio: verse.referencia,
                      libroId: verse.libroId,
                      capituloInicio: verse.capitulo,
                      versiculoInicio: verse.numero,
                      textoSnapshot: verse.texto,
                      etiqueta: selectedTag,
                      color: selectedColor,
                      fechaGuardado: DateTime.now(),
                      notas: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                    );

                    final profileRepo = ref.read(profileRepositoryProvider);
                    await profileRepo.savePassage(passage);
                    ref.invalidate(savedPassagesProvider);
                    ref.invalidate(readingStatsProvider);

                    Navigator.pop(dCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pasaje guardado en tu perfil (${selectedTag})')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddNoteDialog(BibleVerse verse) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Nota en ${verse.referencia}'),
          content: TextField(
            controller: noteController,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Escribe tu reflexión o apunte personal...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (noteController.text.trim().isNotEmpty) {
                  final profileRepo = ref.read(profileRepositoryProvider);
                  await profileRepo.addNote(verse.id, noteController.text.trim());
                  ref.invalidate(readingStatsProvider);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota guardada')),
                );
              },
              child: const Text('Guardar Nota'),
            ),
          ],
        );
      },
    );
  }

  void _showFontDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              title: const Text('Tamaño de fuente'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      if (_fontSize > 14) {
                        setState(() => _fontSize -= 2);
                        setDState(() {});
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('${_fontSize.toInt()} pt', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      if (_fontSize < 32) {
                        setState(() => _fontSize += 2);
                        setDState(() {});
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Listo')),
              ],
            );
          },
        );
      },
    );
  }
}
