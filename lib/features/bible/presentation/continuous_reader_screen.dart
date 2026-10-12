import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/models/bookmark.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';

class ContinuousReaderScreen extends ConsumerStatefulWidget {
  final int initialBookId;
  final int initialChapter;
  final int? initialVerse;

  const ContinuousReaderScreen({
    super.key,
    this.initialBookId = 43, // San Juan por defecto
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
  int _activeBookId = 43;
  int _activeChapter = 1;
  int _activeVerse = 1;
  String _activeRefText = 'Juan 1:1';

  // Preferencias visuales
  double _fontSize = 19.0;
  String _colorMode = 'sepia'; // 'sepia', 'dark', 'light'

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

    if (mounted) {
      setState(() {
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

                    // Texto continuo de corrido
                    SelectableText.rich(
                      TextSpan(
                        style: GoogleFonts.merriweather(
                          fontSize: _fontSize,
                          height: 1.85,
                          color: textColor,
                        ),
                        children: block.verses.expand((verse) {
                          return [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
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
                            TextSpan(text: '${verse.texto} '),
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
