import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/register/register_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/wishlist/wishlist_screen.dart';
import 'features/home/home_page.dart';
import 'features/profile/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Readify Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// 👇 TÁCH RA NGOÀI (đây là fix quan trọng nhất)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _checkingLogin = true;
  bool _loggedIn = false;

  final List<Widget> _pages = const [
    HomePage(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const ['Home', 'Wishlist', 'Cart', 'Profile'];

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) {
      // Chưa đăng nhập, chuyển sang LoginScreen
      final result = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (result == true) {
        setState(() {
          _loggedIn = true;
          _checkingLogin = false;
        });
      } else {
        // Nếu không login thì pop app
        if (mounted) Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _loggedIn = true;
        _checkingLogin = false;
      });
    }
  }

  void _onItemTapped(int index) {
    // If user tries to open protected tabs (Wishlist, Cart, Profile) ensure logged in
    Future.microtask(() async {
      if (index == 0) {
        setState(() => _selectedIndex = index);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        final result = await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        if (result == true) {
          setState(() {
            _loggedIn = true;
            _selectedIndex = index;
          });
        }
      } else {
        setState(() => _selectedIndex = index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 3)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Do you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('accessToken');
                  if (mounted) {
                    setState(() {
                      _loggedIn = false;
                      _checkingLogin = true;
                    });
                    _checkLogin();
                  }
                }
              },
            ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Wishlist'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Readify',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                if (result == true) {
                  setState(() {
                    _loggedIn = true;
                    _checkingLogin = false;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Register'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
