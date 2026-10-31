import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../bible/presentation/bible_screen.dart';
import '../../bible/presentation/continuous_reader_screen.dart';
import '../../bible/presentation/search_screen.dart';
import '../../liturgical_calendar/presentation/calendar_screen.dart';
import '../../profile/models/bookmark.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/presentation/saved_passages_screen.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/today_liturgical_card.dart';
import '../../thematic_suggestions/presentation/thematic_suggestions_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Pantallas principales accesibles desde la barra inferior
    final screens = [
      _buildHomeDashboard(context),
      const BibleScreen(),
      const CalendarScreen(),
      const SavedPassagesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Biblia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_added_rounded),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    final liturgicalDay = ref.watch(currentLiturgicalDayProvider);
    final bookmarkAsync = ref.watch(bookmarkProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ENCABEZADO SUPERIOR VERBUM
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'VERBUM',
                        style: GoogleFonts.cinzel(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'v1.1',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  profileAsync.maybeWhen(
                    data: (p) => Text(
                      'Paz y bien, ${p.nombre}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                    orElse: () => const Text('La Palabra de Dios para tu día a día', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
              // Botón de búsqueda rápida
              IconButton.filledTonal(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                tooltip: 'Buscar en la Sagrada Escritura',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. 🕊️ GUÍA BÍBLICA PARA TU DÍA (Amor, Dinero, Salud, Amistad, Armonía)
          ThematicSuggestionsWidget(
            onOpenReading: (reference) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(initialQuery: reference),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // 2. 🆕 TARJETA "MODO CORRIDO" (Empieza en Génesis 1:1 para usuarios nuevos)
          bookmarkAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (bm) {
              return ContinueReadingCard(
                bookmark: bm,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContinuousReaderScreen(
                        initialBookId: bm?.libroId ?? 1,
                        initialChapter: bm?.capitulo ?? 1,
                        initialVerse: bm?.versiculo ?? 1,
                      ),
                    ),
                  );
                },
                onResetToZero: () async {
                  final zeroBookmark = Bookmark(
                    perfilId: 1,
                    libroId: 1,
                    capitulo: 1,
                    versiculo: 1,
                    modo: 'continuo',
                    fechaActualizacion: DateTime.now(),
                    libroNombre: 'Génesis',
                    libroAbreviatura: 'Gn',
                  );
                  await ref.read(profileRepositoryProvider).saveBookmark(zeroBookmark);
                  ref.invalidate(bookmarkProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modo Corrido reiniciado en Génesis 1:1'),
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 18),

          // 3. TARJETA "HOY" DEL CALENDARIO LITÚRGICO
          TodayLiturgicalCard(
            day: liturgicalDay,
            onOpenCalendar: () {
              setState(() => _currentIndex = 2); // Ir a pestaña de calendario
            },
            onOpenReading: (reference) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(initialQuery: reference),
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // 4. REJILLA DE ACCESOS RÁPIDOS
          QuickActionsGrid(
            onOpenBible: () => setState(() => _currentIndex = 1),
            onOpenContinuous: () {
              final bm = bookmarkAsync.asData?.value;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContinuousReaderScreen(
                    initialBookId: bm?.libroId ?? 1,
                    initialChapter: bm?.capitulo ?? 1,
                    initialVerse: bm?.versiculo ?? 1,
                  ),
                ),
              );
            },
            onOpenCalendar: () => setState(() => _currentIndex = 2),
            onOpenSaved: () => setState(() => _currentIndex = 3),
            onOpenSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            onOpenProfile: () => setState(() => _currentIndex = 4),
          ),
          const SizedBox(height: 22),

          // 4. CITA DEVOCIONAL DESTACADA
          _buildDevotionalInspiration(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDevotionalInspiration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded, color: AppTheme.primaryGold, size: 22),
              const SizedBox(width: 8),
              Text(
                'PALABRA DE VIDA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"Lámpara es a mis pies tu palabra, y lumbrera a mi camino."',
            style: GoogleFonts.merriweather(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— Salmos 119:105 (RVR09)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
