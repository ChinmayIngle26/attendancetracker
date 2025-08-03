import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomBottomBarVariant {
  standard,
  adaptive,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final CustomBottomBarVariant variant;
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.adaptive,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomBottomBarVariant.adaptive:
        return _buildNavigationBar(context, theme);
      case CustomBottomBarVariant.standard:
        return _buildBottomNavigationBar(context, theme);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalNavigationBar(context, theme);
    }
  }

  Widget _buildNavigationBar(BuildContext context, ThemeData theme) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _handleNavigation(context, index),
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      elevation: 8,
      height: 80,
      labelBehavior: showLabels
          ? NavigationDestinationLabelBehavior.alwaysShow
          : NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: _getNavigationDestinations(theme),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleNavigation(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      elevation: 8,
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      items: _getBottomNavigationBarItems(),
    );
  }

  Widget _buildMinimalNavigationBar(BuildContext context, ThemeData theme) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _getMinimalNavigationItems(context, theme),
      ),
    );
  }

  List<NavigationDestination> _getNavigationDestinations(ThemeData theme) {
    return [
      NavigationDestination(
        icon: Icon(
          Icons.dashboard_outlined,
          color: currentIndex == 0
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        selectedIcon: Icon(
          Icons.dashboard,
          color: theme.colorScheme.primary,
        ),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.subject_outlined,
          color: currentIndex == 1
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        selectedIcon: Icon(
          Icons.subject,
          color: theme.colorScheme.primary,
        ),
        label: 'Subjects',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.schedule_outlined,
          color: currentIndex == 2
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        selectedIcon: Icon(
          Icons.schedule,
          color: theme.colorScheme.primary,
        ),
        label: 'Timetable',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.analytics_outlined,
          color: currentIndex == 3
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        selectedIcon: Icon(
          Icons.analytics,
          color: theme.colorScheme.primary,
        ),
        label: 'Statistics',
      ),
    ];
  }

  List<BottomNavigationBarItem> _getBottomNavigationBarItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
        tooltip: 'View dashboard and today\'s schedule',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.subject_outlined),
        activeIcon: Icon(Icons.subject),
        label: 'Subjects',
        tooltip: 'Manage subjects and attendance',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.schedule_outlined),
        activeIcon: Icon(Icons.schedule),
        label: 'Timetable',
        tooltip: 'View and manage timetable',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Statistics',
        tooltip: 'View attendance statistics',
      ),
    ];
  }

  List<Widget> _getMinimalNavigationItems(
      BuildContext context, ThemeData theme) {
    final items = [
      _MinimalNavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        isSelected: currentIndex == 0,
        onTap: () => _handleNavigation(context, 0),
        theme: theme,
      ),
      _MinimalNavItem(
        icon: Icons.subject_outlined,
        selectedIcon: Icons.subject,
        isSelected: currentIndex == 1,
        onTap: () => _handleNavigation(context, 1),
        theme: theme,
      ),
      _MinimalNavItem(
        icon: Icons.schedule_outlined,
        selectedIcon: Icons.schedule,
        isSelected: currentIndex == 2,
        onTap: () => _handleNavigation(context, 2),
        theme: theme,
      ),
      _MinimalNavItem(
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
        isSelected: currentIndex == 3,
        onTap: () => _handleNavigation(context, 3),
        theme: theme,
      ),
    ];

    return items;
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Define route mappings
    final routes = [
      '/dashboard-home',
      '/subject-management',
      '/timetable-management',
      '/attendance-statistics',
    ];

    if (index >= 0 && index < routes.length) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        routes[index],
        (route) => false,
      );
    }

    onTap(index);
  }
}

class _MinimalNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _MinimalNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
      ),
    );
  }
}
