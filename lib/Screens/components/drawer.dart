import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../Services/auth_service.dart';
import '../../main.dart';
import '../oredrs_page.dart';

class DrawerHome extends StatefulWidget {
  const DrawerHome({super.key});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  final _authBox = Hive.box('auth');

  @override
  Widget build(BuildContext context) {
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
              padding: EdgeInsets.only(top: 50, bottom: 20),
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
                  Text(
                    '${_authBox.get('username')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
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
                      title: 'Home',
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(navigatorKey.currentContext!).pushReplacementNamed('/home');
                        });
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.shopping_cart,
                      title: 'My Cart',
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(navigatorKey.currentContext!).pushNamed('/cart');
                        });
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'Order',
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(navigatorKey.currentContext!).push(
                            MaterialPageRoute(
                              builder: (context) => OrdersPage(isSeller: false ),
                            ),
                          );
                        });
                      },
                    ),

                    ...(_authBox.get('role') == 'seller'
                        ? [
                      _buildMenuItem(
                        icon: Icons.car_repair,
                        title: 'My Car Parts',
                        onTap: () {
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(navigatorKey.currentContext!).pushNamed('/mycarparts');
                          });
                        },
                      ),
                    ] : []),

                    ...(_authBox.get('role') == 'seller'
                        ? [
                      _buildMenuItem(
                        icon: Icons.shopping_cart,
                        title: 'Seller Orders',
                        onTap: () {
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(navigatorKey.currentContext!).push(
                              MaterialPageRoute(
                                builder: (context) => OrdersPage(isSeller: true),
                              ),
                            );
                          });
                        },
                      ),
                    ] : []),
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      title: 'Profile Setting',
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(navigatorKey.currentContext!).pushNamed('/profile');
                        });
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.man,
                      title: 'About us',
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(navigatorKey.currentContext!).pushNamed('/aboutus');
                        });
                      },
                    ),
                    Spacer(),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      isLogout: true,
                      onTap: () {
                        AuthService auth = AuthService();
                        auth.logout();
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(navigatorKey.currentContext!).pushReplacementNamed('/login');
                        });
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