import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TimetableContextMenu extends StatelessWidget {
  final Map<String, dynamic> entry;
  final List<Map<String, dynamic>> subjects;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int dayIndex) onDuplicate;
  final VoidCallback onChangeSubject;

  const TimetableContextMenu({
    super.key,
    required this.entry,
    required this.subjects,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onChangeSubject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = subjects.firstWhere(
      (s) => s['id'] == entry['subjectId'],
      orElse: () => {'name': 'Unknown Subject', 'color': '#2E7D32'},
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, subject),
          _buildMenuItems(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> subject) {
    final theme = Theme.of(context);
    final subjectColor = Color(
        int.parse((subject['color'] as String).replaceFirst('#', '0xFF')));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: subjectColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: subjectColor,
                width: 2,
              ),
            ),
            child: Center(
              child: subject['icon'] != null
                  ? CustomIconWidget(
                      iconName: subject['icon'] as String,
                      color: subjectColor,
                      size: 20,
                    )
                  : Text(
                      (subject['name'] as String).substring(0, 1).toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: subjectColor,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['name'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry['room'] != null &&
                    (entry['room'] as String).isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        entry['room'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: 'edit',
            title: 'Edit Class',
            subtitle: 'Modify time, subject, or room',
            onTap: () {
              Navigator.of(context).pop();
              onEdit();
            },
          ),
          _buildMenuItem(
            context,
            icon: 'swap_horiz',
            title: 'Change Subject',
            subtitle: 'Switch to different subject',
            onTap: () {
              Navigator.of(context).pop();
              onChangeSubject();
            },
          ),
          _buildMenuItem(
            context,
            icon: 'content_copy',
            title: 'Duplicate',
            subtitle: 'Copy to other days',
            onTap: () => _showDuplicateOptions(context),
          ),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
          _buildMenuItem(
            context,
            icon: 'delete',
            title: 'Delete Class',
            subtitle: 'Remove from timetable',
            onTap: () => _showDeleteConfirmation(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 10.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: isDestructive
              ? theme.colorScheme.error.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }

  void _showDuplicateOptions(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final currentDayIndex = entry['dayIndex'] as int;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Duplicate to Days',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...weekdays.asMap().entries.map((dayEntry) {
              final dayIndex = dayEntry.key;
              final dayName = dayEntry.value;
              final isCurrentDay = dayIndex == currentDayIndex;

              return ListTile(
                enabled: !isCurrentDay,
                onTap: isCurrentDay
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        onDuplicate(dayIndex);
                      },
                leading: CustomIconWidget(
                  iconName: isCurrentDay
                      ? 'radio_button_checked'
                      : 'radio_button_unchecked',
                  color: isCurrentDay
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  dayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isCurrentDay
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: isCurrentDay
                    ? Text(
                        'Current day',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                        ),
                      )
                    : null,
              );
            }).toList(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final subject = subjects.firstWhere(
      (s) => s['id'] == entry['subjectId'],
      orElse: () => {'name': 'Unknown Subject'},
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Class',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${subject['name']} from your timetable?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text(
              'Delete',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
