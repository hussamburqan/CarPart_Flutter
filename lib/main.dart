import 'package:carparts/Screens/home_screen.dart';
import 'package:carparts/Screens/profile_screen.dart';
import 'package:carparts/Screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'Model/models.dart';
import 'Model/order.dart';
import 'Screens/TOW.dart';
import 'Screens/add_car_part.dart';
import 'Screens/cart_page.dart';
import 'Screens/aboutus.dart';
import 'Screens/edit_my_part.dart';
import 'Screens/login_screen.dart';
import 'Screens/my_car_part.dart';
import 'Screens/oredrs_page.dart';
import 'Services/auth_service.dart';
import 'apptheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('auth');
  Hive.registerAdapter(SellerAdapter());
  Hive.registerAdapter(CarPartAdapter());
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<CartItem>('cartBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _authBox = Hive.box('auth');
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Car Part App',
        theme: AppTheme.lightTheme,
        initialRoute: _authBox.get('accessToken') != null ? '/home' : '/login',
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
        },
      ),
    );
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

