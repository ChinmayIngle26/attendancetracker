import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum ViewType { list, grid }

class ViewToggleWidget extends StatelessWidget {
  final ViewType currentView;
  final Function(ViewType) onViewChanged;

  const ViewToggleWidget({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context: context,
            viewType: ViewType.list,
            icon: 'view_list',
            isSelected: currentView == ViewType.list,
            onTap: () => onViewChanged(ViewType.list),
          ),
          Container(
            width: 1,
            height: 5.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildToggleButton(
            context: context,
            viewType: ViewType.grid,
            icon: 'grid_view',
            isSelected: currentView == ViewType.grid,
            onTap: () => onViewChanged(ViewType.grid),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required ViewType viewType,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 5.w,
        ),
      ),
    );
  }
}
