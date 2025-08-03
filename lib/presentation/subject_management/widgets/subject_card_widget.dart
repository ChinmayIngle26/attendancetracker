import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SubjectCardWidget extends StatelessWidget {
  final Map<String, dynamic> subject;
  final bool isGridView;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool isEditMode;

  const SubjectCardWidget({
    super.key,
    required this.subject,
    required this.isGridView,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attendancePercentage = (subject["attendedLectures"] as int) /
        (subject["totalLectures"] as int > 0
            ? subject["totalLectures"] as int
            : 1) *
        100;
    final isLowAttendance = attendancePercentage < 75.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isGridView ? 1.w : 4.w,
          vertical: 1.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isLowAttendance
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isGridView
            ? _buildGridCard(theme, attendancePercentage, isLowAttendance)
            : _buildListCard(theme, attendancePercentage, isLowAttendance),
      ),
    );
  }

  Widget _buildGridCard(
      ThemeData theme, double attendancePercentage, bool isLowAttendance) {
    return Container(
      padding: EdgeInsets.all(3.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isEditMode)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: theme.colorScheme.onPrimary,
                        size: 4.w,
                      )
                    : null,
              ),
            ),
          SizedBox(height: 1.h),
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Color(subject["color"] as int),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: subject["icon"] as String,
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subject["name"] as String,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isLowAttendance ? theme.colorScheme.error : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            height: 1.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.5.h),
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: attendancePercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.5.h),
                  color: isLowAttendance
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            "${attendancePercentage.toStringAsFixed(1)}%",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isLowAttendance ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(
      ThemeData theme, double attendancePercentage, bool isLowAttendance) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          if (isEditMode) ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: theme.colorScheme.onPrimary,
                      size: 4.w,
                    )
                  : null,
            ),
            SizedBox(width: 3.w),
          ],
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Color(subject["color"] as int),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: subject["icon"] as String,
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject["name"] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLowAttendance ? theme.colorScheme.error : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "${subject["attendedLectures"]}/${subject["totalLectures"]} lectures",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 0.8.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.4.h),
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: attendancePercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0.4.h),
                              color: isLowAttendance
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "${attendancePercentage.toStringAsFixed(1)}%",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLowAttendance
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLowAttendance)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Low",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
