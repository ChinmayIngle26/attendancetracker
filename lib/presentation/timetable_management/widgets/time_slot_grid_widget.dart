import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TimeSlotGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> timeSlots;
  final List<Map<String, dynamic>> subjects;
  final Function(int timeSlotIndex, int dayIndex) onSlotTap;
  final Function(Map<String, dynamic> entry) onEntryTap;
  final Function(Map<String, dynamic> entry) onEntryLongPress;
  final int currentWeekOffset;

  const TimeSlotGridWidget({
    super.key,
    required this.timeSlots,
    required this.subjects,
    required this.onSlotTap,
    required this.onEntryTap,
    required this.onEntryLongPress,
    required this.currentWeekOffset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
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
        children: [
          _buildHeader(context, weekdays),
          Expanded(
            child: SingleChildScrollView(
              child: _buildTimeSlotGrid(context, weekdays),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<String> weekdays) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final currentWeekStart = today
        .subtract(Duration(days: today.weekday - 1))
        .add(Duration(days: currentWeekOffset * 7));

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 15.w,
            child: Text(
              'Time',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...weekdays.asMap().entries.map((entry) {
            final dayIndex = entry.key;
            final dayName = entry.value;
            final dayDate = currentWeekStart.add(Duration(days: dayIndex));
            final isToday = dayDate.day == today.day &&
                dayDate.month == today.month &&
                dayDate.year == today.year;

            return Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isToday
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      dayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      '${dayDate.day}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeSlotGrid(BuildContext context, List<String> weekdays) {
    final theme = Theme.of(context);

    return Column(
      children: timeSlots.asMap().entries.map((timeSlotEntry) {
        final timeSlotIndex = timeSlotEntry.key;
        final timeSlot = timeSlotEntry.value;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _buildTimeSlotLabel(context, timeSlot),
                ...weekdays.asMap().entries.map((dayEntry) {
                  final dayIndex = dayEntry.key;
                  return _buildTimeSlotCell(
                      context, timeSlotIndex, dayIndex, timeSlot);
                }).toList(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotLabel(
      BuildContext context, Map<String, dynamic> timeSlot) {
    final theme = Theme.of(context);

    return Container(
      width: 15.w,
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeSlot['startTime'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '|',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            timeSlot['endTime'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCell(BuildContext context, int timeSlotIndex,
      int dayIndex, Map<String, dynamic> timeSlot) {
    final theme = Theme.of(context);

    // Find if there's a scheduled class for this time slot and day
    final scheduledEntry = _findScheduledEntry(timeSlotIndex, dayIndex);

    return Expanded(
      child: GestureDetector(
        onTap: () => scheduledEntry != null
            ? onEntryTap(scheduledEntry)
            : onSlotTap(timeSlotIndex, dayIndex),
        onLongPress: scheduledEntry != null
            ? () => onEntryLongPress(scheduledEntry)
            : null,
        child: Container(
          margin: EdgeInsets.all(0.5.w),
          height: 8.h,
          decoration: BoxDecoration(
            color: scheduledEntry != null
                ? _getSubjectColor(scheduledEntry['subjectId'])
                    .withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            border: Border.all(
              color: scheduledEntry != null
                  ? _getSubjectColor(scheduledEntry['subjectId'])
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: scheduledEntry != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: scheduledEntry != null
              ? _buildScheduledEntryContent(context, scheduledEntry)
              : _buildEmptySlotContent(context),
        ),
      ),
    );
  }

  Widget _buildScheduledEntryContent(
      BuildContext context, Map<String, dynamic> entry) {
    final theme = Theme.of(context);
    final subject = subjects.firstWhere(
      (s) => s['id'] == entry['subjectId'],
      orElse: () =>
          {'name': 'Unknown', 'abbreviation': 'UK', 'color': '#2E7D32'},
    );

    return Container(
      padding: EdgeInsets.all(1.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            subject['abbreviation'] as String? ?? 'UK',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _getSubjectColor(entry['subjectId']),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (entry['room'] != null &&
              (entry['room'] as String).isNotEmpty) ...[
            SizedBox(height: 0.2.h),
            Text(
              entry['room'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptySlotContent(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: CustomIconWidget(
        iconName: 'add',
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        size: 20,
      ),
    );
  }

  Map<String, dynamic>? _findScheduledEntry(int timeSlotIndex, int dayIndex) {
    // Mock timetable data - in real app, this would come from database
    final mockTimetableEntries = [
      {
        'id': 1,
        'timeSlotIndex': 0,
        'dayIndex': 0,
        'subjectId': 1,
        'room': 'A101',
      },
      {
        'id': 2,
        'timeSlotIndex': 1,
        'dayIndex': 0,
        'subjectId': 2,
        'room': 'B205',
      },
      {
        'id': 3,
        'timeSlotIndex': 0,
        'dayIndex': 1,
        'subjectId': 3,
        'room': 'C301',
      },
      {
        'id': 4,
        'timeSlotIndex': 2,
        'dayIndex': 1,
        'subjectId': 1,
        'room': 'A102',
      },
      {
        'id': 5,
        'timeSlotIndex': 1,
        'dayIndex': 2,
        'subjectId': 4,
        'room': 'Lab1',
      },
      {
        'id': 6,
        'timeSlotIndex': 3,
        'dayIndex': 2,
        'subjectId': 2,
        'room': 'B206',
      },
      {
        'id': 7,
        'timeSlotIndex': 0,
        'dayIndex': 3,
        'subjectId': 5,
        'room': 'D401',
      },
      {
        'id': 8,
        'timeSlotIndex': 2,
        'dayIndex': 3,
        'subjectId': 3,
        'room': 'C302',
      },
      {
        'id': 9,
        'timeSlotIndex': 1,
        'dayIndex': 4,
        'subjectId': 1,
        'room': 'A103',
      },
      {
        'id': 10,
        'timeSlotIndex': 3,
        'dayIndex': 4,
        'subjectId': 4,
        'room': 'Lab2',
      },
    ];

    try {
      return mockTimetableEntries.firstWhere(
        (entry) =>
            entry['timeSlotIndex'] == timeSlotIndex &&
            entry['dayIndex'] == dayIndex,
      );
    } catch (e) {
      return null;
    }
  }

  Color _getSubjectColor(int subjectId) {
    final subject = subjects.firstWhere(
      (s) => s['id'] == subjectId,
      orElse: () => {'color': '#2E7D32'},
    );

    final colorString = subject['color'] as String;
    return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  }
}
