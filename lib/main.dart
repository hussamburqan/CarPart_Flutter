import 'package:carparts/Screens/home_screen.dart';
import 'package:carparts/Screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'Model/models.dart';
import 'Model/order.dart';
import 'Screens/add_car_part.dart';
import 'Screens/auth/TOW.dart';
import 'Screens/auth/register_screen.dart';
import 'Screens/cart_page.dart';
import 'Screens/aboutus.dart';
import 'Screens/auth/forgot_password.dart';
import 'Screens/auth/login_screen.dart';
import 'Screens/my_car_part.dart';
import 'Screens/auth/reset_password.dart';
import 'Screens/auth/verify_forgot_password.dart';
import 'Services/auth_service.dart';
import 'Services/localizations.dart';
import 'apptheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('setting');
  Hive.registerAdapter(SellerAdapter());
  Hive.registerAdapter(CarPartAdapter());
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<CartItem>('cartBox');
  final languageProvider = LanguageProvider();
  await languageProvider.init();
  runApp( MultiProvider(
    providers: [
      Provider(create: (_) => AuthService()),
      ChangeNotifierProvider(create: (_) => languageProvider),
    ],
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          locale: languageProvider.currentLocale,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Car Part App',
          theme: AppTheme.lightTheme,
          initialRoute: Hive.box('auth').get('accessToken') != null ? '/home' : '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => RegisterScreen(),
            '/2fa': (context) => const VerificationCodePage(),
            '/home': (context) => const HomePage(),
            '/profile': (context) => const ProfilePage(),
            '/cart': (context) => const CartPage(),
            '/mycarparts': (context) => MyCarPartsPage(),
            '/add_car_part': (context) => AddProductPage(),
            '/aboutus': (context) => AboutUsPage(),
            '/forgot_password': (context) => const ForgotPasswordPage(),
            '/verify-reset-code': (context) => const VerifyResetCodePage(),
            '/reset-password': (context) => const ResetPasswordPage(),
          },
        );
      },
    );
  }
}

class LanguageProvider extends ChangeNotifier {
  final _setting = Hive.box('setting');
  Locale _locale = Locale('ar', '');

  Locale get currentLocale => _locale;

  Future<void> init() async {
    final langCode = await _setting.get('lang') ?? 'ar';
    _locale = Locale(langCode, '');
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    await _setting.put('lang', languageCode);
    _locale = Locale(languageCode, '');
    notifyListeners();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
