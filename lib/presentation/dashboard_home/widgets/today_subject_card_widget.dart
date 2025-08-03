import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TodaySubjectCardWidget extends StatefulWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onMarkPresent;
  final VoidCallback onMarkAbsent;
  final VoidCallback onViewDetails;
  final VoidCallback onEditAttendance;
  final VoidCallback onSubjectSettings;

  const TodaySubjectCardWidget({
    super.key,
    required this.subject,
    required this.onMarkPresent,
    required this.onMarkAbsent,
    required this.onViewDetails,
    required this.onEditAttendance,
    required this.onSubjectSettings,
  });

  @override
  State<TodaySubjectCardWidget> createState() => _TodaySubjectCardWidgetState();
}

class _TodaySubjectCardWidgetState extends State<TodaySubjectCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = Color(widget.subject['color'] as int);
    final attendanceStatus = widget.subject['attendanceStatus'] as String?;
    final isCompleted = attendanceStatus != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: subjectColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showQuickActions(context),
                onLongPress: () => _showContextMenu(context),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                          theme, subjectColor, isCompleted, attendanceStatus),
                      SizedBox(height: 2.h),
                      _buildTimeSlot(theme),
                      SizedBox(height: 2.h),
                      if (!isCompleted)
                        _buildAttendanceButtons(theme, subjectColor),
                      if (isCompleted)
                        _buildCompletedStatus(theme, attendanceStatus),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, Color subjectColor, bool isCompleted,
      String? attendanceStatus) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: subjectColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: widget.subject['icon'] as String? ?? 'book',
              color: subjectColor,
              size: 24,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subject['name'] as String,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Room ${widget.subject['room'] ?? 'TBA'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isCompleted)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: attendanceStatus == 'present'
                  ? theme.colorScheme.tertiary.withValues(alpha: 0.2)
                  : theme.colorScheme.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName:
                      attendanceStatus == 'present' ? 'check_circle' : 'cancel',
                  color: attendanceStatus == 'present'
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  attendanceStatus == 'present' ? 'Present' : 'Absent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: attendanceStatus == 'present'
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimeSlot(ThemeData theme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'access_time',
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 16,
        ),
        SizedBox(width: 2.w),
        Text(
          '${widget.subject['startTime']} - ${widget.subject['endTime']}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.subject['attendancePercentage']?.toStringAsFixed(1) ?? '0.0'}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceButtons(ThemeData theme, Color subjectColor) {
    return Row(
      children: [
        Expanded(
          child: _buildAttendanceButton(
            theme,
            'Present',
            'check_circle',
            theme.colorScheme.tertiary,
            () => _markAttendance(true),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildAttendanceButton(
            theme,
            'Absent',
            'cancel',
            theme.colorScheme.error,
            () => _markAttendance(false),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceButton(
    ThemeData theme,
    String label,
    String iconName,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedStatus(ThemeData theme, String status) {
    final isPresent = status == 'present';
    final color =
        isPresent ? theme.colorScheme.tertiary : theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isPresent ? 'check_circle' : 'cancel',
            color: color,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(
            'Marked as ${isPresent ? 'Present' : 'Absent'}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _markAttendance(bool isPresent) {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Scale animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Call appropriate callback
    if (isPresent) {
      widget.onMarkPresent();
    } else {
      widget.onMarkAbsent();
    }

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Marked as ${isPresent ? 'Present' : 'Absent'} for ${widget.subject['name']}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              widget.subject['name'] as String,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            _buildActionTile(
                context, 'View Details', 'info', widget.onViewDetails),
            _buildActionTile(
                context, 'Edit Attendance', 'edit', widget.onEditAttendance),
            _buildActionTile(context, 'Subject Settings', 'settings',
                widget.onSubjectSettings),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context, String title, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    _showQuickActions(context);
  }
}
