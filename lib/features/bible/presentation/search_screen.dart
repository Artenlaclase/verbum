import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../models/bible_verse.dart';
import 'chapter_reader_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<BibleVerse> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  final List<String> _quickSearches = [
    'Jn 3:16',
    'Salmo 23',
    'Mateo 5:3',
    'Romanos 8:28',
    '1 Corintios 13',
    'Paz',
    'Amor',
    'Luz',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  Future<void> _performSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
        _lastQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _lastQuery = clean;
    });

    final repo = ref.read(bibleRepositoryProvider);
    final list = await repo.searchVerses(clean);

    if (mounted) {
      setState(() {
        _results = list;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda Bíblica'),
      ),
      body: Column(
        children: [
          // Campo de búsqueda principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              autofocus: widget.initialQuery == null,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: 'Cita (ej. Jn 3:16) o palabra (ej. paz)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2024) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),

          // Sugerencias de búsqueda rápida
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickSearches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final term = _quickSearches[index];
                return ActionChip(
                  label: Text(term, style: const TextStyle(fontSize: 12)),
                  backgroundColor: isDark ? const Color(0xFF26292E) : Colors.white,
                  onPressed: () {
                    _controller.text = term;
                    _performSearch(term);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Resultados
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _lastQuery.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 64, color: Colors.grey.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            const Text(
                              'Escribe una palabra o cita bíblica',
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ejemplos: "Jn 3:16", "Salmo 23", "amor", "oración"',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sentiment_dissatisfied_rounded, size: 48, color: Colors.grey),
                                const SizedBox(height: 10),
                                Text(
                                  'No se encontraron versículos para "$_lastQuery"',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF7F5F0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.auto_stories, size: 16, color: AppTheme.primaryGold),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_results.length} versículo${_results.length == 1 ? "" : "s"} encontrado${_results.length == 1 ? "" : "s"}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Reina-Valera 1909',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isDark ? Colors.white38 : Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _results.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                              final v = _results[index];
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () async {
                                    final bibleRepo = ref.read(bibleRepositoryProvider);
                                    final book = await bibleRepo.getBookById(v.libroId);
                                    if (book != null && context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChapterReaderScreen(
                                            book: book,
                                            chapter: v.capitulo,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              v.referencia,
                                              style: const TextStyle(
                                                color: AppTheme.primaryGold,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          v.texto,
                                          style: const TextStyle(fontSize: 14, height: 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
