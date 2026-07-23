import 'package:flutter/material.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: const Center(
        child: Text('Home — Phase 2 Catalog'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Danh mục'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Giỏ'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
        onDestinationSelected: (index) {
          if (index == 3) {
            // handled by shell route in router
          }
        },
      ),
    );
  }
}
