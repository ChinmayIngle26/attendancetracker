import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  final int totalLectures;
  final int attendedLectures;
  final double attendancePercentage;
  final int lecturesCanBunk;
  final List<Map<String, dynamic>> subjectsBelowThreshold;

  const AttendanceSummaryWidget({
    super.key,
    required this.totalLectures,
    required this.attendedLectures,
    required this.attendancePercentage,
    required this.lecturesCanBunk,
    required this.subjectsBelowThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subjectsBelowThreshold.isNotEmpty) ...[
          _buildWarningSection(context, theme),
          SizedBox(height: 2.h),
        ],
        _buildStatsCards(context, theme),
      ],
    );
  }

  Widget _buildWarningSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: theme.colorScheme.error,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Subjects Below 75% Threshold',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...subjectsBelowThreshold.take(3).map((subject) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  children: [
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: Color(subject['color'] as int),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        '${subject['name']} - ${(subject['percentage'] as double).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (subjectsBelowThreshold.length > 3)
            Text(
              '+${subjectsBelowThreshold.length - 3} more subjects',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            'Total Lectures',
            totalLectures.toString(),
            'school',
            theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            'Attendance',
            '${attendancePercentage.toStringAsFixed(1)}%',
            attendancePercentage >= 75 ? 'trending_up' : 'trending_down',
            attendancePercentage >= 75
                ? theme.colorScheme.tertiary
                : theme.colorScheme.error,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            lecturesCanBunk > 0 ? 'Can Bunk' : 'Need to Attend',
            lecturesCanBunk > 0
                ? lecturesCanBunk.toString()
                : '${lecturesCanBunk.abs()}',
            lecturesCanBunk > 0 ? 'free_breakfast' : 'priority_high',
            lecturesCanBunk > 0
                ? theme.colorScheme.tertiary
                : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String value,
    String iconName,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
