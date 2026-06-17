import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'menu_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';// Kita akan buat file ini setelahnya

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan saat tab ditekan
  final List<Widget> _pages = [
    const HomeScreen(),
    const MenuScreen(),   // Placeholder untuk Menu
    const RewardsScreen(), // Placeholder untuk Rewards
    ProfileScreen(), // Placeholder untuk Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      // NavigationBar adalah versi modern dari BottomNavigationBar di Material 3
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Theme.of(context).colorScheme.primary, // Warna hijau Vivalavida
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.coffee_outlined),
            selectedIcon: Icon(Icons.coffee, color: Colors.white),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star, color: Colors.white),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}