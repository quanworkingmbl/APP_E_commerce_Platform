import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          final count = cartState.cart.itemCount;
          return NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) {
              widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: 'Danh mục',
              ),
              NavigationDestination(
                icon: _cartIcon(count, outlined: true),
                selectedIcon: _cartIcon(count, outlined: false),
                label: 'Giỏ',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Tài khoản',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cartIcon(int count, {required bool outlined}) {
    final icon = Icon(outlined ? Icons.shopping_cart_outlined : Icons.shopping_cart);
    if (count <= 0) return icon;
    return badges.Badge(
      badgeContent: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
      child: icon,
    );
  }
}
