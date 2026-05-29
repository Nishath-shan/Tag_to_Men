import 'package:flutter/material.dart';
import '../theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _go(BuildContext context, int index) {
    if (index == currentIndex) return;

    final routes = ['/home', '/products', '/cart', '/profile'];
    Navigator.pushNamedAndRemoveUntil(
      context,
      routes[index],
      (route) => false,
    );
  }

  BottomNavigationBarItem _item(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _go(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.cardColor,
      selectedItemColor: const Color(0xFF1450F0),
      unselectedItemColor: const Color(0xFF98A2B3),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: [
        _item(Icons.home_rounded, 'Home'),
        _item(Icons.grid_view_rounded, 'Products'),
        _item(Icons.shopping_cart_rounded, 'Cart'),
        _item(Icons.person_rounded, 'Profile'),
      ],
    );
  }
}