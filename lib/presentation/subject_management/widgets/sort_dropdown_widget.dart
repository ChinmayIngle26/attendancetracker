import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum SortType { alphabetical, mostActive, attendancePercentage }

class SortDropdownWidget extends StatelessWidget {
  final SortType currentSort;
  final Function(SortType) onSortChanged;

  const SortDropdownWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortType>(
          value: currentSort,
          onChanged: (SortType? newValue) {
            if (newValue != null) {
              onSortChanged(newValue);
            }
          },
          icon: CustomIconWidget(
            iconName: 'keyboard_arrow_down',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 5.w,
          ),
          items: [
            DropdownMenuItem<SortType>(
              value: SortType.alphabetical,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'sort_by_alpha',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Alphabetical',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            DropdownMenuItem<SortType>(
              value: SortType.mostActive,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Most Active',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            DropdownMenuItem<SortType>(
              value: SortType.attendancePercentage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'percent',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Attendance %',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
