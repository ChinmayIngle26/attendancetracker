import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum AttendanceStatus { present, absent }

class AttendanceOptionsWidget extends StatelessWidget {
  final AttendanceStatus? selectedStatus;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const AttendanceOptionsWidget({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'how_to_reg',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Mark Attendance',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceOption(
                  context: context,
                  status: AttendanceStatus.present,
                  title: 'Present',
                  icon: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  theme: theme,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildAttendanceOption(
                  context: context,
                  status: AttendanceStatus.absent,
                  title: 'Absent',
                  icon: 'cancel',
                  color: theme.colorScheme.error,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOption({
    required BuildContext context,
    required AttendanceStatus status,
    required String title,
    required String icon,
    required Color color,
    required ThemeData theme,
  }) {
    final isSelected = selectedStatus == status;

    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: isSelected
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected ? color : color.withValues(alpha: 0.7),
                size: 8.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 1.h),
              Container(
                width: 6.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(0.25.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
