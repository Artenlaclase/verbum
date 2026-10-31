import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Servicio centralizado de autenticación Firebase.
/// Soporta: Google Sign-In, Email/Password.
class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Estado actual ───────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;

  /// Stream reactivo del estado de autenticación.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Google Sign-In ──────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(provider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // Cancelado por el usuario

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('AuthService signInWithGoogle error: $e');
      rethrow;
    }
  }

  // ─── Email / Password ────────────────────────────────────────
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('AuthService signInWithEmail error: $e');
      rethrow;
    }
  }

  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      return credential;
    } catch (e) {
      debugPrint('AuthService createAccountWithEmail error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Cerrar sesión ───────────────────────────────────────────
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {}
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService signOut error: $e');
      rethrow;
    }
  }

  // ─── Helpers de errores para UI ──────────────────────────────
  static String friendlyError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe una cuenta con ese correo.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese correo.';
        case 'weak-password':
          return 'La contraseña es muy débil (mín. 6 caracteres).';
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde.';
        case 'configuration-not-found':
          return 'Falta habilitar el proveedor en Firebase Console (Authentication > Sign-in method).';
        case 'api-key-not-valid':
          return 'La API Key de Firebase no es válida o aún se está propagando en Google Cloud.';
        case 'popup-closed-by-user':
          return 'Ventana de inicio de sesión cerrada por el usuario.';
        case 'cancelled':
          return 'Inicio de sesión cancelado.';
        default:
          return error.message ?? 'Error de autenticación (${error.code}).';
      }
    }
    return 'Ha ocurrido un error inesperado.';
  }
}
