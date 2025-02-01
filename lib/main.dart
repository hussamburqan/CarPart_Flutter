import 'package:carparts/Screens/home_screen.dart';
import 'package:carparts/Screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Model/user.dart';
import 'Screens/TOW.dart';
import 'Screens/login_screen.dart';
import 'apptheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(UserAdapter());

  // Open Boxes
  await Hive.openBox('auth');
  await Hive.openBox<User>('users');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterScreen(),
        '/2fa': (context) => const VerificationCodePage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

