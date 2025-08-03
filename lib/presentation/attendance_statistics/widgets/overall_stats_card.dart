import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class OverallStatsCard extends StatelessWidget {
  final double overallPercentage;
  final int totalLectures;
  final int attendedLectures;
  final int totalSubjects;

  const OverallStatsCard({
    super.key,
    required this.overallPercentage,
    required this.totalLectures,
    required this.attendedLectures,
    required this.totalSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAboveThreshold = overallPercentage >= 75.0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
            'Overall Attendance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: isAboveThreshold
                            ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
                            : theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${overallPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: isAboveThreshold
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isAboveThreshold ? 'Good Standing' : 'Below Threshold',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isAboveThreshold
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildStatRow(
                      context,
                      'Total Lectures',
                      totalLectures.toString(),
                      CustomIconWidget(
                        iconName: 'school',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildStatRow(
                      context,
                      'Attended',
                      attendedLectures.toString(),
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: theme.colorScheme.tertiary,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildStatRow(
                      context,
                      'Subjects',
                      totalSubjects.toString(),
                      CustomIconWidget(
                        iconName: 'subject',
                        color: theme.colorScheme.secondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, Widget icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        icon,
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
