import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/bible/data/bible_repository.dart';
import '../../features/bible/models/bible_book.dart';
import '../../features/liturgical_calendar/data/liturgical_calculator.dart';
import '../../features/liturgical_calendar/models/liturgical_day.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/models/bookmark.dart';
import '../../features/profile/models/saved_passage.dart';
import '../../features/profile/models/user_profile.dart';
import '../../features/thematic_suggestions/data/thematic_suggestions_repository.dart';
import '../../features/thematic_suggestions/models/thematic_suggestion.dart';

// Repositorios
final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Proveedor del Perfil del usuario
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
});

// Proveedor de estadísticas del perfil
final readingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getReadingStats();
});

// Proveedor del marcador de lectura continua
final bookmarkProvider = FutureProvider<Bookmark?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getBookmark();
});

// Notifier para filtro de etiquetas de pasajes
class SelectedTagNotifier extends Notifier<String> {
  @override
  String build() => 'Todos';
  void setTag(String tag) => state = tag;
}

final selectedTagFilterProvider =
    NotifierProvider<SelectedTagNotifier, String>(SelectedTagNotifier.new);

final savedPassagesProvider = FutureProvider<List<SavedPassage>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final tag = ref.watch(selectedTagFilterProvider);
  return repo.getSavedPassages(etiqueta: tag == 'Todos' ? null : tag);
});

// Notifier para fecha litúrgica seleccionada
class SelectedLiturgicalDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void setDate(DateTime date) => state = date;
}

final selectedLiturgicalDateProvider =
    NotifierProvider<SelectedLiturgicalDateNotifier, DateTime>(SelectedLiturgicalDateNotifier.new);

final currentLiturgicalDayProvider = Provider<LiturgicalDay>((ref) {
  final selectedDate = ref.watch(selectedLiturgicalDateProvider);
  return LiturgicalCalculator.getLiturgicalDay(selectedDate);
});

// Notifier para filtro de testamento (null = Todos, 'AT', 'NT')
class BibleTestamentFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setFilter(String? filter) => state = filter;
}

final bibleTestamentFilterProvider =
    NotifierProvider<BibleTestamentFilterNotifier, String?>(BibleTestamentFilterNotifier.new);

final bibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final filter = ref.watch(bibleTestamentFilterProvider);
  return repo.getBooks(testamento: filter);
});

// Notifier para ThemeMode (claro / oscuro / sistema)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;
  void setThemeMode(ThemeMode mode) => state = mode;
}

final themeModeStateProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// Proveedor de sugerencias bíblicas temáticas diarias
final thematicSuggestionsRepositoryProvider =
    Provider<ThematicSuggestionsRepository>((ref) {
  return ThematicSuggestionsRepository.instance;
});

final dailyThematicSuggestionsProvider =
    Provider<List<ThematicReadingSuggestion>>((ref) {
  final repo = ref.watch(thematicSuggestionsRepositoryProvider);
  return repo.getDailySuggestions();
});

