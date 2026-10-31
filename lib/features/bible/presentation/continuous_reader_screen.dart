import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/liturgical_colors.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../profile/models/bookmark.dart';
import '../../profile/models/saved_passage.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';

class ContinuousReaderScreen extends ConsumerStatefulWidget {
  final int initialBookId;
  final int initialChapter;
  final int? initialVerse;

  const ContinuousReaderScreen({
    super.key,
    this.initialBookId = 1, // Génesis 1:1 por defecto (empezar en cero)
    this.initialChapter = 1,
    this.initialVerse = 1,
  });

  @override
  ConsumerState<ContinuousReaderScreen> createState() => _ContinuousReaderScreenState();
}

class _ChapterBlock {
  final BibleBook book;
  final int chapter;
  final List<BibleVerse> verses;

  _ChapterBlock({
    required this.book,
    required this.chapter,
    required this.verses,
  });
}

class _ContinuousReaderScreenState extends ConsumerState<ContinuousReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<_ChapterBlock> _loadedBlocks = [];

  bool _isLoadingMore = false;
  late int _currentBookId;
  late int _nextChapterToLoad;

  // Marcador dinámico actual
  int _activeBookId = 1;
  int _activeChapter = 1;
  int _activeVerse = 1;
  String _activeRefText = 'Génesis 1:1';

  // Preferencias visuales
  double _fontSize = 19.0;
  String _colorMode = 'sepia'; // 'sepia', 'dark', 'light'
  final Map<int, String> _highlights = {}; // versiculoId -> hex color

  Timer? _autoSaveTimer;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _currentBookId = widget.initialBookId;
    _nextChapterToLoad = widget.initialChapter;
    _activeBookId = widget.initialBookId;
    _activeChapter = widget.initialChapter;
    _activeVerse = widget.initialVerse ?? 1;

    _loadInitialChapters();
    _setupScrollListener();
    _startPeriodicAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPeriodicAutoSave() {
    // Especificación del informe v1.1 (Sección 7.2): Guardado automático cada 30 segundos
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveCurrentBookmark(silent: true);
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Carga infinita al llegar cerca del fondo (85%)
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400 && !_isLoadingMore) {
        _loadNextChapterBlock();
      }

      // Estimar capítulo en pantalla para el marcador
      _estimateCurrentPosition();
    });
  }

  void _estimateCurrentPosition() {
    if (_loadedBlocks.isEmpty) return;
    final total = _loadedBlocks.length;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0) {
      final index = ((currentScroll / maxScroll) * total).floor().clamp(0, total - 1);
      final block = _loadedBlocks[index];
      if (block.chapter != _activeChapter || block.book.id != _activeBookId) {
        setState(() {
          _activeBookId = block.book.id;
          _activeChapter = block.chapter;
          _activeVerse = 1;
          _activeRefText = '${block.book.nombre} ${block.chapter}:1';
        });
      }
    }
  }

  Future<void> _loadInitialChapters() async {
    setState(() => _isLoadingMore = true);
    await _loadNextChapterBlock(isInitial: true);
    // Cargar también el siguiente capítulo por adelantado para suavidad
    await _loadNextChapterBlock();
    setState(() => _isLoadingMore = false);
  }

  Future<void> _loadNextChapterBlock({bool isInitial = false}) async {
    final bibleRepo = ref.read(bibleRepositoryProvider);
    final book = await bibleRepo.getBookById(_currentBookId);
    if (book == null) return;

    if (_nextChapterToLoad > book.totalCapitulos) {
      // Pasar al siguiente libro canónico si se terminó el actual
      final allBooks = await bibleRepo.getBooks();
      final currentIndex = allBooks.indexWhere((b) => b.id == _currentBookId);
      if (currentIndex != -1 && currentIndex + 1 < allBooks.length) {
        _currentBookId = allBooks[currentIndex + 1].id;
        _nextChapterToLoad = 1;
        return _loadNextChapterBlock();
      } else {
        return; // Fin de la Biblia
      }
    }

    final verses = await bibleRepo.getVerses(_currentBookId, _nextChapterToLoad);
    final profileRepo = ref.read(profileRepositoryProvider);
    final hlList = await profileRepo.getHighlightsForChapter(_currentBookId, _nextChapterToLoad);

    if (mounted) {
      setState(() {
        for (final h in hlList) {
          _highlights[h.versiculoId] = h.color;
        }
        if (isInitial) {
          _activeBookId = book.id;
          _activeChapter = _nextChapterToLoad;
          _activeRefText = '${book.nombre} $_nextChapterToLoad:$_activeVerse';
        }
        _loadedBlocks.add(_ChapterBlock(
          book: book,
          chapter: _nextChapterToLoad,
          verses: verses,
        ));
        _nextChapterToLoad++;
      });
    }

    // Registrar en historial
    ref.read(profileRepositoryProvider).logReading(
      libroId: book.id,
      capitulo: _nextChapterToLoad - 1,
    );
  }

  Future<void> _saveCurrentBookmark({bool silent = false}) async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final bookmark = Bookmark(
      perfilId: 1,
      libroId: _activeBookId,
      capitulo: _activeChapter,
      versiculo: _activeVerse,
      modo: 'continuo',
      fechaActualizacion: DateTime.now(),
    );

    await profileRepo.saveBookmark(bookmark);
    ref.invalidate(bookmarkProvider);

    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcador guardado en $_activeRefText'),
          backgroundColor: AppTheme.primaryGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modos de lectura
    Color bgColor;
    Color textColor;
    if (_colorMode == 'sepia') {
      bgColor = const Color(0xFFF6F0E4);
      textColor = const Color(0xFF2E271F);
    } else if (_colorMode == 'dark') {
      bgColor = const Color(0xFF131416);
      textColor = const Color(0xFFDDD7CC);
    } else {
      bgColor = Colors.white;
      textColor = const Color(0xFF1A1A1A);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _controlsVisible
          ? AppBar(
              backgroundColor: bgColor,
              foregroundColor: textColor,
              elevation: 0,
              title: Column(
                children: [
                  const Text(
                    'Modo Corrido',
                    style: TextStyle(fontSize: 13, letterSpacing: 1.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _activeRefText,
                    style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.style_outlined),
                  tooltip: 'Color de fondo',
                  onPressed: _cycleColorMode,
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields_rounded),
                  tooltip: 'Tamaño',
                  onPressed: _showFontDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded),
                  tooltip: 'Ocultar barra',
                  onPressed: () => setState(() => _controlsVisible = false),
                ),
              ],
            )
          : null,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_controlsVisible)
            FloatingActionButton.small(
              heroTag: 'restoreControls',
              backgroundColor: textColor.withOpacity(0.15),
              foregroundColor: textColor,
              onPressed: () => setState(() => _controlsVisible = true),
              child: const Icon(Icons.fullscreen_exit_rounded),
            ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'saveBookmark',
            backgroundColor: AppTheme.primaryGold,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.bookmark_add_rounded),
            label: Text(
              'Marcador ($_activeRefText)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () => _saveCurrentBookmark(silent: false),
          ),
        ],
      ),
      body: _loadedBlocks.isEmpty
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
              itemCount: _loadedBlocks.length + 1,
              itemBuilder: (context, blockIdx) {
                if (blockIdx == _loadedBlocks.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryGold),
                    ),
                  );
                }

                final block = _loadedBlocks[blockIdx];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Separador solemne de capítulo
                    Padding(
                      padding: const EdgeInsets.only(top: 36, bottom: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 1,
                              color: AppTheme.primaryGold.withOpacity(0.6),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${block.book.nombre.toUpperCase()} ${block.chapter}',
                              style: GoogleFonts.cinzel(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 36,
                              height: 1,
                              color: AppTheme.primaryGold.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Texto continuo de corrido (Toca cualquier versículo para guardar, crear nota o subrayar)
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.merriweather(
                          fontSize: _fontSize,
                          height: 1.85,
                          color: textColor,
                        ),
                        children: block.verses.expand((verse) {
                          final highlightColorHex = _highlights[verse.id];
                          Color? highlightBg;
                          if (highlightColorHex != null) {
                            try {
                              final cleanHex = highlightColorHex.replaceAll('#', '');
                              highlightBg = Color(int.parse('0x55$cleanHex'));
                            } catch (_) {}
                          }

                          return [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => _showVerseContextMenu(verse, block.book.nombre),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                                  child: Text(
                                    '${verse.numero}',
                                    style: TextStyle(
                                      fontSize: _fontSize * 0.7,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: '${verse.texto} ',
                              style: highlightBg != null
                                  ? TextStyle(backgroundColor: highlightBg)
                                  : null,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _showVerseContextMenu(verse, block.book.nombre),
                            ),
                          ];
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _showVerseContextMenu(BibleVerse verse, String bookName) {
    final fullRef = '$bookName ${verse.capitulo}:${verse.numero}';
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
                      fullRef,
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
                    if (!_requireAuthForStudy('guardar pasajes favoritos')) return;
                    _showSavePassageDialog(verse, fullRef);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: LiturgicalColors.verde),
                  title: const Text('Añadir nota personal'),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (!_requireAuthForStudy('añadir notas personales')) return;
                    _showAddNoteDialog(verse, fullRef);
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
                  leading: const Icon(Icons.push_pin_outlined, color: AppTheme.primaryGold),
                  title: const Text('Fijar marcador de Modo Corrido aquí'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _activeBookId = verse.libroId;
                      _activeChapter = verse.capitulo;
                      _activeVerse = verse.numero;
                      _activeRefText = fullRef;
                    });
                    _saveCurrentBookmark(silent: false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copiar versículo'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '${verse.texto} ($fullRef RVR09)'));
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

  bool _requireAuthForStudy(String actionLabel) {
    if (AuthService.instance.isSignedIn) return true;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lock_person_rounded, color: AppTheme.primaryGold),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Inicia sesión requerida',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Para $actionLabel y sincronizar tu estudio personal necesitas iniciar sesión en tu cuenta Verbum.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return false;
  }

  Widget _buildColorDot(BibleVerse verse, String colorHex) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        if (!_requireAuthForStudy('subrayar versículos')) return;
        final profileRepo = ref.read(profileRepositoryProvider);
        await profileRepo.addHighlight(verse.id, colorHex);
        ref.invalidate(readingStatsProvider);
        setState(() {
          _highlights[verse.id] = colorHex;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Versículo resaltado')),
          );
        }
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

  void _showSavePassageDialog(BibleVerse verse, String fullRef) {
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
              title: const Row(
                children: [
                  Icon(Icons.bookmark_added_rounded, color: AppTheme.primaryGold),
                  SizedBox(width: 8),
                  Text('Guardar en mi Perfil'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullRef,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${verse.texto}"',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
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
                    final isCustodio = ref.read(isCustodioProvider);
                    final profileRepo = ref.read(profileRepositoryProvider);
                    if (!isCustodio) {
                      final existing = await profileRepo.getSavedPassages();
                      if (existing.length >= VerbumPlanLimits.maxFreePassages) {
                        if (dCtx.mounted) Navigator.pop(dCtx);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Has alcanzado los 5 pasajes de Camino Abierto. Únete como «Custodio de la Palabra» en tu Perfil para guardar sin límite.',
                              ),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                        return;
                      }
                    }

                    final passage = SavedPassage(
                      perfilId: 1,
                      titulo: titleController.text.trim().isNotEmpty ? titleController.text.trim() : null,
                      referenciaInicio: fullRef,
                      libroId: verse.libroId,
                      capituloInicio: verse.capitulo,
                      versiculoInicio: verse.numero,
                      textoSnapshot: verse.texto,
                      etiqueta: selectedTag,
                      color: selectedColor,
                      fechaGuardado: DateTime.now(),
                      notas: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                    );

                    await profileRepo.savePassage(passage);
                    ref.invalidate(savedPassagesProvider);
                    ref.invalidate(readingStatsProvider);

                    if (dCtx.mounted) Navigator.pop(dCtx);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Pasaje guardado en tu perfil ($selectedTag)')),
                      );
                    }
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

  void _showAddNoteDialog(BibleVerse verse, String fullRef) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Nota en $fullRef'),
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
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nota guardada')),
                  );
                }
              },
              child: const Text('Guardar Nota'),
            ),
          ],
        );
      },
    );
  }

  void _cycleColorMode() {
    setState(() {
      if (_colorMode == 'sepia') {
        _colorMode = 'dark';
      } else if (_colorMode == 'dark') {
        _colorMode = 'light';
      } else {
        _colorMode = 'sepia';
      }
    });
  }

  void _showFontDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              title: const Text('Ajuste de Lectura'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                          if (_fontSize < 34) {
                            setState(() => _fontSize += 2);
                            setDState(() {});
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: const Text('Pergamino'),
                        selected: _colorMode == 'sepia',
                        onSelected: (_) {
                          setState(() => _colorMode = 'sepia');
                          setDState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Noche'),
                        selected: _colorMode == 'dark',
                        onSelected: (_) {
                          setState(() => _colorMode = 'dark');
                          setDState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Claro'),
                        selected: _colorMode == 'light',
                        onSelected: (_) {
                          setState(() => _colorMode = 'light');
                          setDState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
              ],
            );
          },
        );
      },
    );
  }
}
