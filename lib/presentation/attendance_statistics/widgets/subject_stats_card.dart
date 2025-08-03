import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SubjectStatsCard extends StatefulWidget {
  final Map<String, dynamic> subject;
  final VoidCallback? onTap;
  final VoidCallback? onAdjustAttendance;

  const SubjectStatsCard({
    super.key,
    required this.subject,
    this.onTap,
    this.onAdjustAttendance,
  });

  @override
  State<SubjectStatsCard> createState() => _SubjectStatsCardState();
}

class _SubjectStatsCardState extends State<SubjectStatsCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectName = widget.subject['name'] as String? ?? 'Unknown Subject';
    final totalLectures = widget.subject['totalLectures'] as int? ?? 0;
    final attendedLectures = widget.subject['attendedLectures'] as int? ?? 0;
    final percentage =
        totalLectures > 0 ? (attendedLectures / totalLectures) * 100 : 0.0;
    final isAboveThreshold = percentage >= 75.0;
    final subjectColor = Color(widget.subject['color'] as int? ?? 0xFF2E7D32);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAboveThreshold
              ? theme.colorScheme.outline.withValues(alpha: 0.2)
              : theme.colorScheme.error.withValues(alpha: 0.3),
          width: isAboveThreshold ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: subjectColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subjectName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '$attendedLectures/$totalLectures lectures',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 15.w,
                        height: 15.w,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sections: _buildPieChartSections(
                                  attendedLectures,
                                  totalLectures - attendedLectures,
                                  theme,
                                  subjectColor,
                                ),
                                sectionsSpace: 2,
                                centerSpaceRadius: 5.w,
                                startDegreeOffset: -90,
                              ),
                            ),
                            Center(
                              child: Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isAboveThreshold
                                      ? theme.colorScheme.tertiary
                                      : theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: _isExpanded ? 'expand_less' : 'expand_more',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 24,
                      ),
                    ],
                  ),
                  if (!isAboveThreshold) ...[
                    SizedBox(height: 2.h),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'warning',
                            color: theme.colorScheme.error,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Below 75% threshold',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
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
            ),
          ),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildExpandedContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, ThemeData theme) {
    final totalLectures = widget.subject['totalLectures'] as int? ?? 0;
    final attendedLectures = widget.subject['attendedLectures'] as int? ?? 0;
    final percentage =
        totalLectures > 0 ? (attendedLectures / totalLectures) * 100 : 0.0;
    final canBunk = _calculateBunkLectures(attendedLectures, totalLectures);
    final needToAttend =
        _calculateRequiredLectures(attendedLectures, totalLectures);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Statistics',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Current %',
                  '${percentage.toStringAsFixed(1)}%',
                  CustomIconWidget(
                    iconName: 'percent',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Can Bunk',
                  canBunk.toString(),
                  CustomIconWidget(
                    iconName: 'free_breakfast',
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Need to Attend',
                  needToAttend.toString(),
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: theme.colorScheme.tertiary,
                    size: 16,
                  ),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Trend',
                  percentage >= 75 ? 'Good' : 'Critical',
                  CustomIconWidget(
                    iconName:
                        percentage >= 75 ? 'trending_up' : 'trending_down',
                    color: percentage >= 75
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.error,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onAdjustAttendance,
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  label: const Text('Adjust'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBunkCalculator(context),
                  icon: CustomIconWidget(
                    iconName: 'calculate',
                    color: theme.colorScheme.onPrimary,
                    size: 16,
                  ),
                  label: const Text('Calculator'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, Widget icon) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    int attended,
    int missed,
    ThemeData theme,
    Color subjectColor,
  ) {
    final total = attended + missed;
    if (total == 0) {
      return [
        PieChartSectionData(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          value: 100,
          radius: 3.w,
          showTitle: false,
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: subjectColor,
        value: attended.toDouble(),
        radius: 3.w,
        showTitle: false,
      ),
      PieChartSectionData(
        color: theme.colorScheme.error.withValues(alpha: 0.3),
        value: missed.toDouble(),
        radius: 3.w,
        showTitle: false,
      ),
    ];
  }

  int _calculateBunkLectures(int attended, int total) {
    if (total == 0) return 0;
    final currentPercentage = (attended / total) * 100;
    if (currentPercentage <= 75) return 0;

    // Calculate how many lectures can be bunked while staying above 75%
    int canBunk = 0;
    int tempTotal = total;
    while (tempTotal > 0 && (attended / (tempTotal + 1)) * 100 >= 75) {
      canBunk++;
      tempTotal++;
    }
    return canBunk;
  }

  int _calculateRequiredLectures(int attended, int total) {
    if (total == 0) return 0;
    final currentPercentage = (attended / total) * 100;
    if (currentPercentage >= 75) return 0;

    // Calculate how many lectures need to be attended to reach 75%
    int required = 0;
    int tempAttended = attended;
    int tempTotal = total;

    while ((tempAttended / tempTotal) * 100 < 75) {
      tempAttended++;
      tempTotal++;
      required++;
    }

    return required;
  }

  void _showBunkCalculator(BuildContext context) {
    final theme = Theme.of(context);
    final totalLectures = widget.subject['totalLectures'] as int? ?? 0;
    final attendedLectures = widget.subject['attendedLectures'] as int? ?? 0;
    final canBunk = _calculateBunkLectures(attendedLectures, totalLectures);
    final needToAttend =
        _calculateRequiredLectures(attendedLectures, totalLectures);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bunk Calculator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subject['name'] as String? ?? 'Subject',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            if (canBunk > 0) ...[
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'free_breakfast',
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'You can bunk $canBunk more lectures and still maintain 75% attendance.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ] else if (needToAttend > 0) ...[
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'You need to attend $needToAttend more lectures to reach 75% attendance.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'You are exactly at the 75% threshold. Attend all future lectures to maintain it.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
