import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp/utils/theme.dart';

class BottomNavigationScaffold extends StatelessWidget {
  const BottomNavigationScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: navigationShell,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: _buildNavigationBarDecoration(),
      child: SafeArea(
        child: _buildNavigationContent(),
      ),
    );
  }

  BoxDecoration _buildNavigationBarDecoration() {
    return const BoxDecoration(
      color: AppTheme.primaryColor,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    );
  }

  Widget _buildNavigationContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHomeNavigationItem(),
          _buildWorkoutsNavigationItem(),
        ],
      ),
    );
  }

  Widget _buildHomeNavigationItem() {
    return _NavItem(
      label: 'Home',
      isSelected: navigationShell.currentIndex == 0,
      onTap: () => _handleNavigationTap(0),
    );
  }

  Widget _buildWorkoutsNavigationItem() {
    return _NavItem(
      label: 'Workouts',
      isSelected: navigationShell.currentIndex == 1,
      onTap: () => _handleNavigationTap(1),
    );
  }

  void _handleNavigationTap(int selectedIndex) {
    navigationShell.goBranch(
      selectedIndex,
      initialLocation: selectedIndex == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;

  final bool isSelected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: _buildNavigationItemContent(),
    );
  }

  Widget _buildNavigationItemContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label,
        style: _buildNavigationItemTextStyle(),
      ),
    );
  }

  TextStyle _buildNavigationItemTextStyle() {
    return TextStyle(
      color: isSelected ? Colors.white : Colors.white70,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      fontSize: 16,
    );
  }
}
