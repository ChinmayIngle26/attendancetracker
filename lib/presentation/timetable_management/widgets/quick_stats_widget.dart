import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final int currentWeekOffset;

  const QuickStatsWidget({
    super.key,
    required this.subjects,
    required this.currentWeekOffset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _calculateWeeklyStats();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: 'schedule',
                  title: 'Total Classes',
                  value: '${stats['totalClasses']}',
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: 'subject',
                  title: 'Subjects',
                  value: '${stats['activeSubjects']}',
                  color: theme.colorScheme.secondary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: 'access_time',
                  title: 'Hours',
                  value: '${stats['totalHours']}h',
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          if (stats['busyDay'] != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Busiest day: ${stats['busyDay']} (${stats['busyDayClasses']} classes)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateWeeklyStats() {
    // Mock timetable data for calculations
    final mockTimetableEntries = [
      {'timeSlotIndex': 0, 'dayIndex': 0, 'subjectId': 1, 'duration': 1.5},
      {'timeSlotIndex': 1, 'dayIndex': 0, 'subjectId': 2, 'duration': 1.5},
      {'timeSlotIndex': 0, 'dayIndex': 1, 'subjectId': 3, 'duration': 1.5},
      {'timeSlotIndex': 2, 'dayIndex': 1, 'subjectId': 1, 'duration': 1.5},
      {'timeSlotIndex': 1, 'dayIndex': 2, 'subjectId': 4, 'duration': 2.0},
      {'timeSlotIndex': 3, 'dayIndex': 2, 'subjectId': 2, 'duration': 1.5},
      {'timeSlotIndex': 0, 'dayIndex': 3, 'subjectId': 5, 'duration': 1.5},
      {'timeSlotIndex': 2, 'dayIndex': 3, 'subjectId': 3, 'duration': 1.5},
      {'timeSlotIndex': 1, 'dayIndex': 4, 'subjectId': 1, 'duration': 1.5},
      {'timeSlotIndex': 3, 'dayIndex': 4, 'subjectId': 4, 'duration': 2.0},
    ];

    final totalClasses = mockTimetableEntries.length;
    final activeSubjects =
        mockTimetableEntries.map((entry) => entry['subjectId']).toSet().length;

    final totalHours = mockTimetableEntries.fold<double>(
        0, (sum, entry) => sum + (entry['duration'] as double));

    // Calculate busiest day
    final dayClasses = <int, int>{};
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    for (final entry in mockTimetableEntries) {
      final dayIndex = entry['dayIndex'] as int;
      dayClasses[dayIndex] = (dayClasses[dayIndex] ?? 0) + 1;
    }

    String? busyDay;
    int busyDayClasses = 0;

    if (dayClasses.isNotEmpty) {
      final busyDayEntry =
          dayClasses.entries.reduce((a, b) => a.value > b.value ? a : b);
      busyDay = weekdays[busyDayEntry.key];
      busyDayClasses = busyDayEntry.value;
    }

    return {
      'totalClasses': totalClasses,
      'activeSubjects': activeSubjects,
      'totalHours': totalHours.toInt(),
      'busyDay': busyDay,
      'busyDayClasses': busyDayClasses,
    };
  }
}
