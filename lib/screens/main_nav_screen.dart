import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'home/home_screen.dart';
import 'catalog/catalog_screen.dart';
import 'sell/sell_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

/// Root shell holding the 5-tab bottom navigation, as specified:
/// Главная, Каталог, Продать, Заказы, Профиль.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await AuthService().currentUser();
    if (mounted) setState(() => _user = u);
  }

  List<Widget> get _screens => [
        HomeScreen(user: _user, onUserChanged: _loadUser),
        const CatalogScreen(),
        SellScreen(user: _user),
        OrdersScreen(user: _user),
        ProfileScreen(user: _user, onUserChanged: _loadUser),
      ];

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: VorexColors.bgDeep,
        body: Center(child: CircularProgressIndicator(color: VorexColors.accentBright)),
      );
    }
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_index), child: _screens[_index]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Каталог'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), label: 'Продать'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Заказы'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Профиль'),
        ],
      ),
    );
  }
}
