import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/subject_selection_sheet.dart';
import './widgets/time_slot_grid_widget.dart';
import './widgets/timetable_context_menu.dart';
import './widgets/week_navigation_widget.dart';

class TimetableManagement extends StatefulWidget {
  const TimetableManagement({super.key});

  @override
  State<TimetableManagement> createState() => _TimetableManagementState();
}

class _TimetableManagementState extends State<TimetableManagement>
    with TickerProviderStateMixin {
  int _currentWeekOffset = 0;
  bool _isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Mock data for time slots
  final List<Map<String, dynamic>> _timeSlots = [
    {'id': 1, 'startTime': '09:00', 'endTime': '10:30'},
    {'id': 2, 'startTime': '10:45', 'endTime': '12:15'},
    {'id': 3, 'startTime': '13:00', 'endTime': '14:30'},
    {'id': 4, 'startTime': '14:45', 'endTime': '16:15'},
    {'id': 5, 'startTime': '16:30', 'endTime': '18:00'},
  ];

  // Mock subjects data
  final List<Map<String, dynamic>> _subjects = [
    {
      'id': 1,
      'name': 'Data Structures & Algorithms',
      'abbreviation': 'DSA',
      'color': '#2E7D32',
      'icon': 'code',
      'totalLectures': 45,
      'attendedLectures': 38,
    },
    {
      'id': 2,
      'name': 'Database Management Systems',
      'abbreviation': 'DBMS',
      'color': '#1565C0',
      'icon': 'storage',
      'totalLectures': 40,
      'attendedLectures': 32,
    },
    {
      'id': 3,
      'name': 'Computer Networks',
      'abbreviation': 'CN',
      'color': '#F57C00',
      'icon': 'network_check',
      'totalLectures': 35,
      'attendedLectures': 28,
    },
    {
      'id': 4,
      'name': 'Software Engineering',
      'abbreviation': 'SE',
      'color': '#7B1FA2',
      'icon': 'engineering',
      'totalLectures': 42,
      'attendedLectures': 35,
    },
    {
      'id': 5,
      'name': 'Operating Systems',
      'abbreviation': 'OS',
      'color': '#C62828',
      'icon': 'computer',
      'totalLectures': 38,
      'attendedLectures': 30,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Timetable',
        variant: CustomAppBarVariant.withActions,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            WeekNavigationWidget(
              currentWeekOffset: _currentWeekOffset,
              onWeekChanged: _handleWeekChanged,
              onTodayPressed: _handleTodayPressed,
            ),
            QuickStatsWidget(
              subjects: _subjects,
              currentWeekOffset: _currentWeekOffset,
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(context)
                  : TimeSlotGridWidget(
                      timeSlots: _timeSlots,
                      subjects: _subjects,
                      onSlotTap: _handleSlotTap,
                      onEntryTap: _handleEntryTap,
                      onEntryLongPress: _handleEntryLongPress,
                      currentWeekOffset: _currentWeekOffset,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleQuickAddClass,
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'Add Class',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 2,
        onTap: _handleBottomNavigation,
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading timetable...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Timetable refreshed successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _handleWeekChanged(int newOffset) {
    setState(() {
      _currentWeekOffset = newOffset;
    });
  }

  void _handleTodayPressed() {
    setState(() {
      _currentWeekOffset = 0;
    });
  }

  void _handleSlotTap(int timeSlotIndex, int dayIndex) {
    _showSubjectSelectionSheet(
      timeSlotIndex: timeSlotIndex,
      dayIndex: dayIndex,
    );
  }

  void _handleEntryTap(Map<String, dynamic> entry) {
    _showSubjectSelectionSheet(
      timeSlotIndex: entry['timeSlotIndex'] as int,
      dayIndex: entry['dayIndex'] as int,
      existingEntry: entry,
    );
  }

  void _handleEntryLongPress(Map<String, dynamic> entry) {
    _showContextMenu(entry);
  }

  void _handleQuickAddClass() {
    final now = DateTime.now();
    final currentHour = now.hour;

    // Find the next available time slot
    int suggestedTimeSlot = 0;
    for (int i = 0; i < _timeSlots.length; i++) {
      final startTime = _timeSlots[i]['startTime'] as String;
      final hour = int.parse(startTime.split(':')[0]);
      if (hour > currentHour) {
        suggestedTimeSlot = i;
        break;
      }
    }

    _showSubjectSelectionSheet(
      timeSlotIndex: suggestedTimeSlot,
      dayIndex: now.weekday - 1, // Convert to 0-based index
    );
  }

  void _showSubjectSelectionSheet({
    required int timeSlotIndex,
    required int dayIndex,
    Map<String, dynamic>? existingEntry,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SubjectSelectionSheet(
          subjects: _subjects,
          existingEntry: existingEntry,
          onSubjectSelected: (subjectId, room) {
            _handleSubjectSelected(
              timeSlotIndex: timeSlotIndex,
              dayIndex: dayIndex,
              subjectId: subjectId,
              room: room,
              existingEntry: existingEntry,
            );
          },
        ),
      ),
    );
  }

  void _showContextMenu(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => TimetableContextMenu(
        entry: entry,
        subjects: _subjects,
        onEdit: () => _handleEditEntry(entry),
        onDelete: () => _handleDeleteEntry(entry),
        onDuplicate: (dayIndex) => _handleDuplicateEntry(entry, dayIndex),
        onChangeSubject: () => _handleChangeSubject(entry),
      ),
    );
  }

  void _handleSubjectSelected({
    required int timeSlotIndex,
    required int dayIndex,
    required int subjectId,
    String? room,
    Map<String, dynamic>? existingEntry,
  }) {
    final subject = _subjects.firstWhere((s) => s['id'] == subjectId);
    final timeSlot = _timeSlots[timeSlotIndex];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final action = existingEntry != null ? 'updated' : 'added';
    final message =
        '${subject['name']} $action for ${weekdays[dayIndex]} at ${timeSlot['startTime']}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.lightTheme.colorScheme.onPrimary,
          onPressed: () {
            // Handle undo functionality
          },
        ),
      ),
    );

    setState(() {
      // In a real app, this would update the database
    });
  }

  void _handleEditEntry(Map<String, dynamic> entry) {
    _showSubjectSelectionSheet(
      timeSlotIndex: entry['timeSlotIndex'] as int,
      dayIndex: entry['dayIndex'] as int,
      existingEntry: entry,
    );
  }

  void _handleDeleteEntry(Map<String, dynamic> entry) {
    final subject = _subjects.firstWhere(
      (s) => s['id'] == entry['subjectId'],
      orElse: () => {'name': 'Unknown Subject'},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${subject['name']} removed from timetable'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.lightTheme.colorScheme.onError,
          onPressed: () {
            // Handle undo functionality
          },
        ),
      ),
    );

    setState(() {
      // In a real app, this would update the database
    });
  }

  void _handleDuplicateEntry(Map<String, dynamic> entry, int targetDayIndex) {
    final subject = _subjects.firstWhere(
      (s) => s['id'] == entry['subjectId'],
      orElse: () => {'name': 'Unknown Subject'},
    );
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${subject['name']} duplicated to ${weekdays[targetDayIndex]}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    setState(() {
      // In a real app, this would update the database
    });
  }

  void _handleChangeSubject(Map<String, dynamic> entry) {
    _showSubjectSelectionSheet(
      timeSlotIndex: entry['timeSlotIndex'] as int,
      dayIndex: entry['dayIndex'] as int,
      existingEntry: entry,
    );
  }

  static void _handleBottomNavigation(int index) {
    // Navigation handled by CustomBottomBar
  }
}
