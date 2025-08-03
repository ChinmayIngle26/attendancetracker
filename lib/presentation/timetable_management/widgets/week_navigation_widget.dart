import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WeekNavigationWidget extends StatelessWidget {
  final int currentWeekOffset;
  final Function(int offset) onWeekChanged;
  final VoidCallback onTodayPressed;

  const WeekNavigationWidget({
    super.key,
    required this.currentWeekOffset,
    required this.onWeekChanged,
    required this.onTodayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final currentWeekStart = today
        .subtract(Duration(days: today.weekday - 1))
        .add(Duration(days: currentWeekOffset * 7));
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationButton(
            context,
            icon: 'chevron_left',
            onPressed: () => onWeekChanged(currentWeekOffset - 1),
            tooltip: 'Previous week',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _getWeekTitle(currentWeekStart, currentWeekEnd),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getDateRange(currentWeekStart, currentWeekEnd),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _buildNavigationButton(
            context,
            icon: 'chevron_right',
            onPressed: () => onWeekChanged(currentWeekOffset + 1),
            tooltip: 'Next week',
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required String icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        padding: EdgeInsets.all(1.w),
        constraints: BoxConstraints(
          minWidth: 10.w,
          minHeight: 5.h,
        ),
      ),
    );
  }

  String _getWeekTitle(DateTime start, DateTime end) {
    final today = DateTime.now();
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    if (start.isAtSameMomentAs(thisWeekStart)) {
      return 'This Week';
    } else if (start.isBefore(thisWeekStart)) {
      final weeksDiff = thisWeekStart.difference(start).inDays ~/ 7;
      return weeksDiff == 1 ? 'Last Week' : '\$weeksDiff Weeks Ago';
    } else {
      final weeksDiff = start.difference(thisWeekStart).inDays ~/ 7;
      return weeksDiff == 1 ? 'Next Week' : 'In \$weeksDiff Weeks';
    }
  }

  String _getDateRange(DateTime start, DateTime end) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    if (start.month == end.month) {
      return '${start.day} - ${end.day} ${months[start.month - 1]} ${start.year}';
    } else if (start.year == end.year) {
      return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${start.year}';
    } else {
      return '${start.day} ${months[start.month - 1]} ${start.year} - ${end.day} ${months[end.month - 1]} ${end.year}';
    }
  }
}
