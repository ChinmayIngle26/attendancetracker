import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  centered,
  minimal,
  withActions,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: _buildTitle(context),
      centerTitle: _shouldCenterTitle(),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      automaticallyImplyLeading: automaticallyImplyLeading && showBackButton,
      backgroundColor: backgroundColor ?? _getBackgroundColor(theme),
      foregroundColor: foregroundColor ?? _getForegroundColor(theme),
      elevation: elevation ?? _getElevation(),
      scrolledUnderElevation: _getScrolledUnderElevation(),
      titleTextStyle: _getTitleTextStyle(theme),
      iconTheme: IconThemeData(
        color: foregroundColor ?? _getForegroundColor(theme),
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? _getForegroundColor(theme),
        size: 24,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    switch (variant) {
      case CustomAppBarVariant.minimal:
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
        );
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.centered:
      case CustomAppBarVariant.withActions:
      default:
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        );
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton || !automaticallyImplyLeading) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    switch (variant) {
      case CustomAppBarVariant.withActions:
        return actions ?? _getDefaultActions(context);
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.centered:
        return actions;
      case CustomAppBarVariant.minimal:
        return null;
      default:
        return actions;
    }
  }

  List<Widget> _getDefaultActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // Navigate to search functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Search functionality coming soon')),
          );
        },
        tooltip: 'Search',
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => _handleMenuSelection(context, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text('Settings'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(Icons.download),
                SizedBox(width: 8),
                Text('Export Data'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                Icon(Icons.help_outline),
                SizedBox(width: 8),
                Text('Help'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings coming soon')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export functionality coming soon')),
        );
        break;
      case 'help':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help documentation coming soon')),
        );
        break;
    }
  }

  bool _shouldCenterTitle() {
    switch (variant) {
      case CustomAppBarVariant.centered:
        return true;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.minimal:
      case CustomAppBarVariant.withActions:
      default:
        return false;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    return theme.colorScheme.surface;
  }

  Color _getForegroundColor(ThemeData theme) {
    return theme.colorScheme.onSurface;
  }

  double _getElevation() {
    switch (variant) {
      case CustomAppBarVariant.minimal:
        return 0;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.centered:
      case CustomAppBarVariant.withActions:
      default:
        return 0;
    }
  }

  double _getScrolledUnderElevation() {
    switch (variant) {
      case CustomAppBarVariant.minimal:
        return 0;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.centered:
      case CustomAppBarVariant.withActions:
      default:
        return 1;
    }
  }

  TextStyle _getTitleTextStyle(ThemeData theme) {
    final baseStyle = GoogleFonts.inter(
      color: foregroundColor ?? _getForegroundColor(theme),
      letterSpacing: 0.15,
    );

    switch (variant) {
      case CustomAppBarVariant.minimal:
        return baseStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        );
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.centered:
      case CustomAppBarVariant.withActions:
      default:
        return baseStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
