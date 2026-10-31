import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_sync_service.dart';
import '../../../core/theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.instance.signInWithGoogle();
      if (result != null && mounted) {
        // Migrar datos locales en segundo plano sin bloquear la navegación
        unawaited(FirestoreSyncService.instance.migrateLocalToFirestore());
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        // Si el usuario simplemente cerró la ventana emergente, no mostrar error alarmante
        if (e is FirebaseAuthException &&
            (e.code == 'popup-closed-by-user' || e.code == 'cancelled')) {
          return;
        }
        setState(() {
          _errorMessage = AuthService.friendlyError(e);
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isLogin) {
        await AuthService.instance.signInWithEmail(
          email: email,
          password: password,
        );
      } else {
        try {
          await AuthService.instance.createAccountWithEmail(
            email: email,
            password: password,
            displayName: _nameController.text.trim(),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // Si la cuenta ya existe, intentar iniciar sesión directamente
            await AuthService.instance.signInWithEmail(
              email: email,
              password: password,
            );
          } else {
            rethrow;
          }
        }
      }
      // Si el correo aún no ha sido verificado (ej. cuenta recién creada o correo no confirmado),
      // exigir confirmación por enlace dentro del tiempo límite; si no se confirma, cerrar sesión.
      if (!AuthService.instance.isEmailVerified) {
        if (mounted) setState(() => _isLoading = false);
        final verified = await _showEmailVerificationCountdownDialog(email);
        if (!verified) {
          await AuthService.instance.cancelUnverifiedSession();
          if (mounted) {
            setState(() {
              _errorMessage =
                  'No se confirmó el correo "$email" a tiempo. Se ha cerrado la sesión; por favor ingrese un correo válido y real.';
            });
          }
          return;
        }
      }

      // Migrar datos locales en segundo plano sin bloquear la navegación
      unawaited(FirestoreSyncService.instance.migrateLocalToFirestore());
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthService.friendlyError(e);
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu correo para restablecer la contraseña.');
      return;
    }
    try {
      await AuthService.instance.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo de recuperación enviado a $email'),
            backgroundColor: AppTheme.primaryGold,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = AuthService.friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardColor = isDark
        ? AppTheme.darkCard.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.95);
    final textColor = isDark ? Colors.white : const Color(0xFF1F1B16);
    final subtleColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryGold.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.burgundyDeep.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cruz decorativa
                        _buildCrossEmblem(),
                        const SizedBox(height: 16),

                        // Título
                        Text(
                          'VERBUM',
                          style: GoogleFonts.cinzel(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin ? 'Inicia sesión para sincronizar' : 'Crea tu cuenta Verbum',
                          style: GoogleFonts.merriweather(
                            fontSize: 13,
                            color: subtleColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tarjeta del formulario
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryGold.withValues(alpha: 0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Botón Google
                                _buildGoogleButton(isDark),
                                const SizedBox(height: 20),

                                // Separador
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: subtleColor.withValues(alpha: 0.3))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'o con correo',
                                        style: TextStyle(fontSize: 12, color: subtleColor),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: subtleColor.withValues(alpha: 0.3))),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Campo nombre (solo registro)
                                if (!_isLogin) ...[
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Nombre',
                                    icon: Icons.person_outline,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 14),
                                ],

                                // Campo email
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Correo electrónico',
                                  icon: Icons.email_outlined,
                                  isDark: isDark,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: AuthService.validateEmailAddress,
                                ),
                                const SizedBox(height: 14),

                                // Campo contraseña
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Contraseña',
                                  icon: Icons.lock_outline,
                                  isDark: isDark,
                                  obscure: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: subtleColor,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                                    if (!_isLogin && v.length < 6) return 'Mínimo 6 caracteres';
                                    return null;
                                  },
                                ),

                                // Link olvidó contraseña
                                if (_isLogin) ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _handleResetPassword,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.only(top: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        '¿Olvidaste tu contraseña?',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryGold.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // Error
                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(color: Colors.red, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Botón principal
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleEmailAuth,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGold,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black,
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                                            style: GoogleFonts.cinzel(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Alternar login/registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?',
                              style: TextStyle(color: subtleColor, fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _errorMessage = null;
                                });
                              },
                              child: Text(
                                _isLogin ? 'Regístrate' : 'Inicia sesión',
                                style: TextStyle(
                                  color: AppTheme.primaryGold,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Botón volver
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.arrow_back, size: 16, color: subtleColor),
                          label: Text(
                            'Continuar sin cuenta',
                            style: TextStyle(color: subtleColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrossEmblem() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Resplandor
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryGold.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Barra vertical
          Positioned(
            top: 4,
            child: Container(
              width: 6,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE6C25B), AppTheme.primaryGold],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          // Barra horizontal
          Positioned(
            top: 16,
            child: Container(
              width: 36,
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6C25B), AppTheme.primaryGold],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade50,
        ),
        icon: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            'G',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: Color(0xFF4285F4),
              fontFamily: 'sans-serif',
            ),
          ),
        ),
        label: Text(
          'Continuar con Google',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.black45,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryGold.withValues(alpha: 0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryGold.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Muestra un diálogo con cuenta regresiva para que el usuario confirme su correo real.
  /// Si el tiempo se agota o el usuario cancela sin confirmar, retorna `false` y cierra la sesión.
  Future<bool> _showEmailVerificationCountdownDialog(String email) async {
    const int totalSeconds = 120; // 2 minutos para confirmar el correo
    int remainingSeconds = totalSeconds;
    bool isChecking = false;
    Timer? countdownTimer;
    Timer? pollTimer;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (!ctx.mounted) {
                t.cancel();
                return;
              }
              if (remainingSeconds <= 1) {
                t.cancel();
                pollTimer?.cancel();
                Navigator.of(dialogCtx).pop(false);
              } else {
                setDialogState(() => remainingSeconds--);
              }
            });

            pollTimer ??= Timer.periodic(const Duration(seconds: 4), (t) async {
              if (!ctx.mounted) {
                t.cancel();
                return;
              }
              final verified = await AuthService.instance.checkEmailVerified();
              if (verified && ctx.mounted) {
                t.cancel();
                countdownTimer?.cancel();
                Navigator.of(dialogCtx).pop(true);
              }
            });

            final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
            final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.mark_email_unread_rounded, color: AppTheme.primaryGold),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Confirma tu correo electrónico',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hemos enviado un enlace de verificación a:',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Abre tu bandeja de entrada y haz clic en el enlace para demostrar que el correo existe. Si no se confirma antes de que termine el tiempo, la sesión se cerrará automáticamente.',
                    style: TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 18, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Text(
                            'Tiempo restante: $minutes:$seconds',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    pollTimer?.cancel();
                    Navigator.of(dialogCtx).pop(false);
                  },
                  child: const Text(
                    'Cancelar / Corregir correo',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12.5),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await AuthService.instance.resendVerificationEmail();
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Enlace de verificación reenviado')),
                        );
                      }
                    } catch (_) {}
                  },
                  child: const Text('Reenviar correo', style: TextStyle(fontSize: 12.5)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: isChecking
                      ? null
                      : () async {
                          setDialogState(() => isChecking = true);
                          final verified = await AuthService.instance.checkEmailVerified();
                          if (!ctx.mounted) return;
                          setDialogState(() => isChecking = false);
                          if (verified) {
                            countdownTimer?.cancel();
                            pollTimer?.cancel();
                            Navigator.of(dialogCtx).pop(true);
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Aún no detectamos la confirmación. Haz clic en el enlace enviado a tu correo.',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(
                    isChecking ? 'Verificando...' : 'Ya confirmé mi correo',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    countdownTimer?.cancel();
    pollTimer?.cancel();
    return result == true;
  }
}
