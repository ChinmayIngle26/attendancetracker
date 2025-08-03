import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/attendance_options_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/notes_field_widget.dart';
import './widgets/recent_entries_widget.dart';
import './widgets/subject_dropdown_widget.dart';
import './widgets/time_picker_widget.dart';

class ManualAttendanceEntry extends StatefulWidget {
  const ManualAttendanceEntry({super.key});

  @override
  State<ManualAttendanceEntry> createState() => _ManualAttendanceEntryState();
}

class _ManualAttendanceEntryState extends State<ManualAttendanceEntry> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));
  String? _selectedSubjectId;
  AttendanceStatus? _selectedStatus;
  String _notes = '';
  TimeOfDay? _selectedTime;
  bool _isBulkMode = false;
  bool _isLoading = false;

  // Mock data for subjects and timetable
  final List<Map<String, dynamic>> _allSubjects = [
    {
      'id': 'sub1',
      'name': 'Data Structures & Algorithms',
      'color': 0xFF2E7D32,
      'icon': 'code',
    },
    {
      'id': 'sub2',
      'name': 'Database Management Systems',
      'color': 0xFF1565C0,
      'icon': 'storage',
    },
    {
      'id': 'sub3',
      'name': 'Operating Systems',
      'color': 0xFFE65100,
      'icon': 'computer',
    },
    {
      'id': 'sub4',
      'name': 'Software Engineering',
      'color': 0xFF7B1FA2,
      'icon': 'engineering',
    },
    {
      'id': 'sub5',
      'name': 'Computer Networks',
      'color': 0xFFC62828,
      'icon': 'network_check',
    },
  ];

  final List<Map<String, dynamic>> _recentEntries = [
    {
      'id': 'entry1',
      'subjectId': 'sub1',
      'subjectName': 'Data Structures & Algorithms',
      'subjectColor': 0xFF2E7D32,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'time': const TimeOfDay(hour: 10, minute: 30),
      'status': 'Present',
      'notes': 'Covered binary trees and traversal algorithms',
    },
    {
      'id': 'entry2',
      'subjectId': 'sub2',
      'subjectName': 'Database Management Systems',
      'subjectColor': 0xFF1565C0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'time': const TimeOfDay(hour: 14, minute: 0),
      'status': 'Absent',
      'notes': 'Medical appointment',
    },
    {
      'id': 'entry3',
      'subjectId': 'sub3',
      'subjectName': 'Operating Systems',
      'subjectColor': 0xFFE65100,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'time': null,
      'status': 'Present',
      'notes': '',
    },
    {
      'id': 'entry4',
      'subjectId': 'sub4',
      'subjectName': 'Software Engineering',
      'subjectColor': 0xFF7B1FA2,
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'time': const TimeOfDay(hour: 11, minute: 15),
      'status': 'Present',
      'notes': 'Project presentation and feedback session',
    },
    {
      'id': 'entry5',
      'subjectId': 'sub5',
      'subjectName': 'Computer Networks',
      'subjectColor': 0xFFC62828,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'time': const TimeOfDay(hour: 9, minute: 0),
      'status': 'Absent',
      'notes': 'Family emergency',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      appBar: _buildAppBar(theme),
      body: _isLoading ? _buildLoadingState(theme) : _buildMainContent(theme),
      floatingActionButton: _buildSaveButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: CustomIconWidget(
          iconName: 'close',
          color: theme.colorScheme.onSurface,
          size: 6.w,
        ),
      ),
      title: Text(
        _isBulkMode ? 'Bulk Entry Mode' : 'Manual Attendance Entry',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _toggleBulkMode,
          icon: CustomIconWidget(
            iconName: _isBulkMode ? 'person' : 'group',
            color: theme.colorScheme.primary,
            size: 5.w,
          ),
          label: Text(
            _isBulkMode ? 'Single' : 'Bulk',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 3.h),
          Text(
            'Saving attendance entry...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isBulkMode) _buildBulkModeInfo(theme),
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDateChanged: _onDateChanged,
          ),
          SizedBox(height: 3.h),
          SubjectDropdownWidget(
            selectedSubjectId: _selectedSubjectId,
            availableSubjects: _getAvailableSubjects(),
            onSubjectChanged: _onSubjectChanged,
          ),
          SizedBox(height: 3.h),
          AttendanceOptionsWidget(
            selectedStatus: _selectedStatus,
            onStatusChanged: _onStatusChanged,
          ),
          SizedBox(height: 3.h),
          TimePickerWidget(
            selectedTime: _selectedTime,
            onTimeChanged: _onTimeChanged,
            isVisible: _selectedSubjectId != null,
          ),
          if (_selectedSubjectId != null) SizedBox(height: 3.h),
          NotesFieldWidget(
            notes: _notes,
            onNotesChanged: _onNotesChanged,
          ),
          SizedBox(height: 4.h),
          RecentEntriesWidget(
            recentEntries: _recentEntries,
            onViewAll: _onViewAllEntries,
          ),
          SizedBox(height: 12.h), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildBulkModeInfo(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: theme.colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulk Entry Mode',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Add multiple attendance entries in a single session',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    final canSave = _selectedSubjectId != null && _selectedStatus != null;

    return Container(
      width: 90.w,
      height: 7.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      child: ElevatedButton(
        onPressed: canSave ? _saveAttendanceEntry : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          foregroundColor: canSave
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          elevation: canSave ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'save',
              color: canSave
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              _isBulkMode ? 'Add Entry' : 'Save Attendance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: canSave
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableSubjects() {
    // In a real app, this would filter subjects based on timetable for the selected date
    // For now, return all subjects as available
    return _allSubjects;
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedSubjectId = null; // Reset subject selection when date changes
      _selectedTime = null; // Reset time selection
    });
  }

  void _onSubjectChanged(String? subjectId) {
    setState(() {
      _selectedSubjectId = subjectId;
      _selectedTime = null; // Reset time when subject changes
    });
  }

  void _onStatusChanged(AttendanceStatus status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _onNotesChanged(String notes) {
    setState(() {
      _notes = notes;
    });
  }

  void _onTimeChanged(TimeOfDay? time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _toggleBulkMode() {
    setState(() {
      _isBulkMode = !_isBulkMode;
    });
  }

  void _onViewAllEntries() {
    // Navigate to full recent entries view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Full recent entries view coming soon'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _saveAttendanceEntry() async {
    if (_selectedSubjectId == null || _selectedStatus == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Check for duplicate entry
    final isDuplicate = _checkForDuplicateEntry();

    if (isDuplicate && mounted) {
      setState(() {
        _isLoading = false;
      });

      _showDuplicateEntryDialog();
      return;
    }

    // Save the entry (in real app, this would save to database)
    final newEntry = {
      'id': 'entry_${DateTime.now().millisecondsSinceEpoch}',
      'subjectId': _selectedSubjectId!,
      'subjectName': _getSubjectName(_selectedSubjectId!),
      'subjectColor': _getSubjectColor(_selectedSubjectId!),
      'date': _selectedDate,
      'time': _selectedTime,
      'status':
          _selectedStatus == AttendanceStatus.present ? 'Present' : 'Absent',
      'notes': _notes,
      'isManualEntry': true,
      'createdAt': DateTime.now(),
    };

    if (mounted) {
      setState(() {
        _isLoading = false;
        _recentEntries.insert(0, newEntry);
        if (_recentEntries.length > 5) {
          _recentEntries.removeLast();
        }
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Attendance entry saved successfully',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
      );

      if (_isBulkMode) {
        // Reset form for next entry in bulk mode
        _resetForm();
      } else {
        // Navigate back in single entry mode
        Navigator.of(context).pop();
      }
    }
  }

  bool _checkForDuplicateEntry() {
    // Check if an entry already exists for the same date and subject
    return _recentEntries.any((entry) {
      final entryDate = entry['date'] as DateTime;
      final entrySubjectId = entry['subjectId'] as String;

      return entryDate.year == _selectedDate.year &&
          entryDate.month == _selectedDate.month &&
          entryDate.day == _selectedDate.day &&
          entrySubjectId == _selectedSubjectId;
    });
  }

  void _showDuplicateEntryDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: theme.colorScheme.error,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Duplicate Entry',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'An attendance entry already exists for ${_getSubjectName(_selectedSubjectId!)} on ${_formatDialogDate(_selectedDate)}.\n\nWould you like to update the existing entry?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateExistingEntry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(
              'Update Entry',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateExistingEntry() {
    // Update existing entry logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Attendance entry updated successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    if (!_isBulkMode) {
      Navigator.of(context).pop();
    } else {
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _selectedDate = DateTime.now().subtract(const Duration(days: 1));
      _selectedSubjectId = null;
      _selectedStatus = null;
      _notes = '';
      _selectedTime = null;
    });
  }

  String _getSubjectName(String subjectId) {
    final subject = _allSubjects.firstWhere(
      (s) => s['id'] == subjectId,
      orElse: () => {'name': 'Unknown Subject'},
    );
    return subject['name'] as String;
  }

  int _getSubjectColor(String subjectId) {
    final subject = _allSubjects.firstWhere(
      (s) => s['id'] == subjectId,
      orElse: () => {'color': 0xFF2E7D32},
    );
    return subject['color'] as int;
  }

  String _formatDialogDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
