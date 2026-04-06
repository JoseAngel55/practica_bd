import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practica_bd/firebase_options.dart';
import 'package:practica_bd/screens/dashboard_screen.dart';
import 'package:practica_bd/screens/login_screen.dart';
import 'package:practica_bd/screens/nueva_venta_screen.dart';
import 'package:practica_bd/screens/register_screen.dart';
import 'package:practica_bd/utils/theme_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetCore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      home: LoginScreen(),
      routes: {
        '/login':       (context) => LoginScreen(),
        '/register':    (context) => RegisterScreen(),
        '/dash':        (context) => DashboardScreen(),
        '/nueva_venta': (_)       => const NuevaVentaScreen(),
      },
    );
  }
}