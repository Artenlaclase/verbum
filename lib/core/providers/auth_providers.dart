import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_sync_service.dart';

/// Provider del servicio de autenticación (singleton).
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Stream reactivo del estado de autenticación.
/// Emite el User actual cada vez que cambia (login/logout).
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.instance.authStateChanges;
});

/// Provider de conveniencia: ¿hay un usuario autenticado?
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user != null) ?? false;
});

/// Nombre / email del usuario autenticado para mostrar en UI.
final userDisplayNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
    data: (user) => user?.displayName ?? user?.email,
  );
});

/// Provider del servicio Firestore Sync.
final firestoreSyncProvider = Provider<FirestoreSyncService>((ref) {
  return FirestoreSyncService.instance;
});
