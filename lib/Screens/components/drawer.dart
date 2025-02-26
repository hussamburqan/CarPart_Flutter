import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../Services/auth_service.dart';
import '../../Services/localizations.dart'; // Import your localization service
import '../../main.dart';
import '../oredrs_page.dart';

class DrawerHome extends StatefulWidget {
  const DrawerHome({super.key});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  final _authBox = Hive.box('auth');

  void _navigateTo(String route) {
    if (route == '/home') {
      Navigator.pop(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(navigatorKey.currentContext!).pushReplacementNamed(route);
      });
      return;
    }
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(navigatorKey.currentContext!).pushNamed(route);
    });
  }

  void _navigateToPage(Widget page) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(builder: (context) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 10),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Spacer(flex: 1),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.language,
                          color: Colors.white,
                        ),
                        onSelected: (String newLang) async {
                          if (newLang != null) {
                            languageProvider.changeLanguage(newLang);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'en',
                            child: Row(
                              children: [
                                Icon(Icons.language, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.translate('english')!),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'ar',
                            child: Row(
                              children: [
                                Icon(Icons.language, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.translate('arabic')!),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Spacer(flex: 1),
                      Text(
                        '${_authBox.get('username')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(flex: 3),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    _buildMenuItem(
                      icon: Icons.home_rounded,
                      title: AppLocalizations.of(context)!.translate('home')!,
                      onTap: () => _navigateTo('/home'),
                    ),
                    _buildMenuItem(
                      icon: Icons.shopping_cart,
                      title: AppLocalizations.of(context)!.translate('my_cart')!,
                      onTap: () => _navigateTo('/cart'),
                    ),
                    _buildMenuItem(
                      icon: Icons.calendar_month_rounded,
                      title: AppLocalizations.of(context)!.translate('order')!,
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(navigatorKey.currentContext!).push(
                            MaterialPageRoute(
                              builder: (context) => OrdersPage(isSeller: false),
                            ),
                          );
                        });
                      },
                    ),
                    if (_authBox.get('role') == 'seller') ...[
                      _buildMenuItem(
                        icon: Icons.car_repair,
                        title: AppLocalizations.of(context)!.translate('my_car_parts')!,
                        onTap: () => _navigateTo('/mycarparts'),
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_cart,
                        title: AppLocalizations.of(context)!.translate('seller_orders')!,
                        onTap: () => _navigateToPage(OrdersPage(isSeller: true)),
                      ),
                    ],
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      title: AppLocalizations.of(context)!.translate('profile_setting')!,
                      onTap: () => _navigateTo('/profile'),
                    ),
                    _buildMenuItem(
                      icon: Icons.man,
                      title: AppLocalizations.of(context)!.translate('about_us')!,
                      onTap: () => _navigateTo('/aboutus'),
                    ),
                    Spacer(),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: AppLocalizations.of(context)!.translate('logout')!,
                      isLogout: true,
                      onTap: () async {
                        final auth = AuthService();
                        await auth.logout(context);
                        _navigateTo('/login');
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isLogout ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Color(0xFF1E40AF),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}