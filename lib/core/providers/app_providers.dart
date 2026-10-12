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

// Proveedor de pasajes guardados filtrables
final selectedTagFilterProvider = StateProvider<String>((ref) => 'Todos');

final savedPassagesProvider = FutureProvider<List<SavedPassage>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final tag = ref.watch(selectedTagFilterProvider);
  return repo.getSavedPassages(etiqueta: tag == 'Todos' ? null : tag);
});

// Proveedor del día litúrgico seleccionado (por defecto hoy)
final selectedLiturgicalDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final currentLiturgicalDayProvider = Provider<LiturgicalDay>((ref) {
  final selectedDate = ref.watch(selectedLiturgicalDateProvider);
  return LiturgicalCalculator.getLiturgicalDay(selectedDate);
});

// Proveedor de libros bíblicos
final bibleTestamentFilterProvider = StateProvider<String?>((ref) => null); // null = Todos, 'AT', 'NT'

final bibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final filter = ref.watch(bibleTestamentFilterProvider);
  return repo.getBooks(testamento: filter);
});

// Proveedor de modo oscuro / claro
final themeModeStateProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
