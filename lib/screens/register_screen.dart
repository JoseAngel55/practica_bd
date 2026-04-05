import 'package:flutter/material.dart';
import 'package:practica_bd/firebase/email_auth.dart';
import 'package:practica_bd/utils/theme_app.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _conEmail = TextEditingController();
  final _conPass  = TextEditingController();
  final _conPass2 = TextEditingController();
  final EmailAuth _emailAuth = EmailAuth();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading  = false;

  @override
  void dispose() {
    _conEmail.dispose();
    _conPass.dispose();
    _conPass2.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_conPass.text != _conPass2.text) {
      _snack('// ERROR: las contraseñas no coinciden', AppTheme.neonRed);
      return;
    }
    if (_conEmail.text.trim().isEmpty || _conPass.text.isEmpty) {
      _snack('// ERROR: completa todos los campos', AppTheme.neonRed);
      return;
    }

    setState(() => _loading = true);
    final ok =
        await _emailAuth.createUser(_conEmail.text.trim(), _conPass.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      _snack('// CUENTA CREADA — verifica tu correo', AppTheme.neonGreen);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      _snack('// ERROR al crear cuenta', AppTheme.neonRed);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.bgElevated,
      showCloseIcon: true,
      closeIconColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          // Cuadrícula de fondo
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.bgDeep.withOpacity(0.6),
                    AppTheme.bgDeep.withOpacity(0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.chevron_left,
                          color: AppTheme.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      const Text('VOLVER',
                          style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              letterSpacing: 2)),
                    ]),
                  ),

                  const SizedBox(height: 32),

                  // Brand
                  Row(children: [
                    Container(width: 3, height: 40, color: AppTheme.neonBlue),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        'NUEVO ACCESO',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 22,
                          color: AppTheme.neonBlue,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                                color: AppTheme.neonBlue.withOpacity(0.4),
                                blurRadius: 10)
                          ],
                        ),
                      ),
                      const Text(
                        'REGISTRO DE TÉCNICO / OPERADOR',
                        style: TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 9,
                            color: AppTheme.textMuted,
                            letterSpacing: 2),
                      ),
                    ]),
                  ]),

                  const SizedBox(height: 36),

                  // Divider con label
                  Row(children: [
                    Expanded(child: Container(height: 1,
                        color: AppTheme.borderIdle)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('CREDENCIALES',
                          style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 9,
                              color: AppTheme.textMuted,
                              letterSpacing: 2)),
                    ),
                    Expanded(child: Container(height: 1,
                        color: AppTheme.borderIdle)),
                  ]),

                  const SizedBox(height: 24),

                  // Email
                  const Text('CORREO ELECTRÓNICO',
                      style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 9,
                          color: AppTheme.textMuted,
                          letterSpacing: 2)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _conEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'ShareTechMono',
                        fontSize: 14),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email, size: 15),
                      hintText: 'tecnico@netcore.mx',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Password
                  const Text('CONTRASEÑA',
                      style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 9,
                          color: AppTheme.textMuted,
                          letterSpacing: 2)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _conPass,
                    obscureText: _obscure1,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'ShareTechMono',
                        fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 15),
                      hintText: '••••••••',
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure1 = !_obscure1),
                        child: Icon(
                          _obscure1
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Confirm password
                  const Text('CONFIRMAR CONTRASEÑA',
                      style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 9,
                          color: AppTheme.textMuted,
                          letterSpacing: 2)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _conPass2,
                    obscureText: _obscure2,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'ShareTechMono',
                        fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 15),
                      hintText: '••••••••',
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure2 = !_obscure2),
                        child: Icon(
                          _obscure2
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Botón registrar
                  GestureDetector(
                    onTap: _loading ? null : _register,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue.withOpacity(0.1),
                        border: Border.all(
                            color: _loading
                                ? AppTheme.borderIdle
                                : AppTheme.neonBlue,
                            width: 1.5),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: AppTheme.neonBlue,
                                  strokeWidth: 1.5))
                          : Text(
                              '> CREAR ACCESO',
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 13,
                                letterSpacing: 3,
                                color: AppTheme.neonBlue,
                                shadows: [
                                  Shadow(
                                      color:
                                          AppTheme.neonBlue.withOpacity(0.5),
                                      blurRadius: 8)
                                ],
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Link a login
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('¿Ya tienes acceso? ',
                        style: TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 11,
                            color: AppTheme.textMuted)),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 11,
                          color: AppTheme.neonBlue,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.neonBlue,
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3048).withOpacity(0.4)
      ..strokeWidth = 0.5;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
    // Líneas de cuadrícula muy sutiles
    final gridPaint = Paint()
      ..color = const Color(0xFF1E3048).withOpacity(0.15)
      ..strokeWidth = 0.3;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
