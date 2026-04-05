import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:practica_bd/firebase/email_auth.dart';
import 'package:practica_bd/utils/theme_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _obscure = true;
  final _conEmail = TextEditingController();
  final _conPass = TextEditingController();
  final EmailAuth _emailAuth = EmailAuth();

  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _scanAnim = Tween<double>(begin: -0.05, end: 1.05)
        .animate(CurvedAnimation(parent: _scanCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _conEmail.dispose();
    _conPass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final ok = await _emailAuth.Login(_conEmail.text, _conPass.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/dash');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('// ERROR: credenciales inválidas o sin verificar'),
          backgroundColor: AppTheme.bgElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    //final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/rack_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF080C10), Color(0xFF0A1628)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
          ),

          // ── Overlay oscuro degradado ──────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.bgDeep.withOpacity(0.85),
                    AppTheme.bgDeep.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Línea de escaneo animada ──────────────────────────
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) => Positioned(
              top: h * _scanAnim.value,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.neonGreen.withOpacity(0.25),
                      AppTheme.neonGreen.withOpacity(0.6),
                      AppTheme.neonGreen.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Logo / Brand
                    Row(children: [
                      Container(
                        width: 3, height: 48,
                        color: AppTheme.neonGreen,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NETCORE',
                            style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 28,
                              color: AppTheme.neonGreen,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                    color: AppTheme.neonGreen.withOpacity(0.5),
                                    blurRadius: 12)
                              ],
                            ),
                          ),
                          const Text(
                            'NETWORK SERVICES & SOLUTIONS',
                            style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 9,
                              color: AppTheme.textSecondary,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ]),

                    const SizedBox(height: 40),

                    // Terminal prompt label
                    const Text(
                      '> AUTENTICACIÓN DE ACCESO',
                      style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1, color: AppTheme.borderIdle),
                    const SizedBox(height: 24),

                    // Campo email
                    const Text('USUARIO / CORREO',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono', fontSize: 10,
                          color: AppTheme.textMuted, letterSpacing: 2)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _conEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: 'ShareTechMono',
                          fontSize: 14),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.terminal, size: 16),
                        hintText: 'usuario@netcore.mx',
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Campo password
                    const Text('CONTRASEÑA',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono', fontSize: 10,
                          color: AppTheme.textMuted, letterSpacing: 2)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _conPass,
                      obscureText: _obscure,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: 'ShareTechMono',
                          fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 16),
                        hintText: '••••••••',
                        suffixIcon: GestureDetector(
                          onTap: () =>
                              setState(() => _obscure = !_obscure),
                          child: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botón login — usa la animación Lottie como trigger
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? Center(
                              child: Lottie.asset(
                                'assets/loginanimation.json',
                                height: 60,
                              ),
                            )
                          : GestureDetector(
                              onTap: _login,
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppTheme.neonGreen.withOpacity(0.08),
                                  border: Border.all(
                                      color: AppTheme.neonGreen, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.chevron_right,
                                        color: AppTheme.neonGreen, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'INICIAR SESIÓN',
                                      style: TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 13,
                                        letterSpacing: 3,
                                        color: AppTheme.neonGreen,
                                        shadows: [
                                          Shadow(
                                              color: AppTheme.neonGreen
                                                  .withOpacity(0.6),
                                              blurRadius: 8)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Link registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sin acceso? ',
                            style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 11,
                                color: AppTheme.textMuted)),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'SOLICITAR CUENTA',
                            style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 11,
                              color: AppTheme.neonGreen,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.neonGreen,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Status bar inferior
                    Row(children: [
                      Container(width: 6, height: 6,
                          decoration: const BoxDecoration(
                              color: AppTheme.neonGreen,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('SISTEMA OPERATIVO  //  v2.4.1',
                          style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 9,
                              color: AppTheme.textMuted,
                              letterSpacing: 1.5)),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cuadrícula de puntos de fondo cuando no hay imagen
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3048).withOpacity(0.6)
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
