import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/attendance_summary_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/today_subject_card_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  
  // Mock user data
  final String _userName = "Alex Johnson";
  final DateTime _currentDate = DateTime.now();
  
  // Mock attendance data
  final List<Map<String, dynamic>> _mockSubjects = [
    { 
      'id': 1,
      'name': 'Advanced Mathematics',
      'icon': 'calculate',
      'color': 0xFF2196F3,
      'room': 'A-101',
      'startTime': '09:00 AM',
      'endTime': '10:30 AM',
      'totalLectures': 45,
      'attendedLectures': 38,
      'attendancePercentage': 84.4,
      'attendanceStatus': null,
    },
    { 
      'id': 2,
      'name': 'Computer Science',
      'icon': 'computer',
      'color': 0xFF4CAF50,
      'room': 'B-205',
      'startTime': '11:00 AM',
      'endTime': '12:30 PM',
      'totalLectures': 42,
      'attendedLectures': 35,
      'attendancePercentage': 83.3,
      'attendanceStatus': null,
    },
    { 
      'id': 3,
      'name': 'Physics Laboratory',
      'icon': 'science',
      'color': 0xFFFF9800,
      'room': 'Lab-3',
      'startTime': '02:00 PM',
      'endTime': '04:00 PM',
      'totalLectures': 28,
      'attendedLectures': 18,
      'attendancePercentage': 64.3,
      'attendanceStatus': 'present',
    },
    { 
      'id': 4,
      'name': 'English Literature',
      'icon': 'menu_book',
      'color': 0xFF9C27B0,
      'room': 'C-301',
      'startTime': '04:30 PM',
      'endTime': '05:30 PM',
      'totalLectures': 38,
      'attendedLectures': 25,
      'attendancePercentage': 65.8,
      'attendanceStatus': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTodaysSchedule();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTodaysSchedule() {
    // Simulate loading today's schedule based on current day
    // In a real app, this would filter subjects based on timetable
    setState(() {
      // Mock: Show different subjects based on day of week
      final dayOfWeek = DateTime.now().weekday;
      if (dayOfWeek == 6 || dayOfWeek == 7) {
        // Weekend - no classes
        _mockSubjects.clear();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Recalculate attendance percentages
    _recalculateAttendance();
    
    setState(() {
      _isRefreshing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance data refreshed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _recalculateAttendance() {
    for (var subject in _mockSubjects) {
      final total = subject['totalLectures'] as int;
      final attended = subject['attendedLectures'] as int;
      subject['attendancePercentage'] = total > 0 ? (attended / total) * 100 : 0.0;
    }
  }

  double get _overallAttendancePercentage {
    if (_mockSubjects.isEmpty) return 0.0;
    
    int totalLectures = 0;
    int totalAttended = 0;
    
    for (var subject in _mockSubjects) {
      totalLectures += subject['totalLectures'] as int;
      totalAttended += subject['attendedLectures'] as int;
    }
    
    return totalLectures > 0 ? (totalAttended / totalLectures) * 100 : 0.0;
  }

  int get _totalLectures {
    return _mockSubjects.fold(0, (sum, subject) => sum + (subject['totalLectures'] as int));
  }

  int get _totalAttendedLectures {
    return _mockSubjects.fold(0, (sum, subject) => sum + (subject['attendedLectures'] as int));
  }

  int get _lecturesCanBunk {
    // Calculate how many lectures can be bunked while maintaining 75% attendance
    final currentPercentage = _overallAttendancePercentage;
    if (currentPercentage < 75) {
      // Need to attend more lectures
      final requiredAttended = (_totalLectures * 0.75).ceil();
      return _totalAttendedLectures - requiredAttended;
    } else {
      // Can bunk some lectures
      final maxAbsent = (_totalLectures * 0.25).floor();
      final currentAbsent = _totalLectures - _totalAttendedLectures;
      return maxAbsent - currentAbsent;
    }
  }

  List<Map<String, dynamic>> get _subjectsBelowThreshold {
    return _mockSubjects.where((subject) => 
      (subject['attendancePercentage'] as double) < 75.0
    ).toList();
  }

  void _markAttendance(int subjectId, bool isPresent) {
    setState(() {
      final subjectIndex = _mockSubjects.indexWhere((s) => s['id'] == subjectId);
      if (subjectIndex != -1) {
        _mockSubjects[subjectIndex]['attendanceStatus'] = isPresent ? 'present' : 'absent';
        
        if (isPresent) {
          _mockSubjects[subjectIndex]['attendedLectures'] += 1;
        }
        _mockSubjects[subjectIndex]['totalLectures'] += 1;
        
        // Recalculate percentage
        final total = _mockSubjects[subjectIndex]['totalLectures'] as int;
        final attended = _mockSubjects[subjectIndex]['attendedLectures'] as int;
        _mockSubjects[subjectIndex]['attendancePercentage'] = (attended / total) * 100;
      }
    });
  }

  void _navigateToManualAttendance() {
    Navigator.pushNamed(context, '/manual-attendance-entry');
  }

  void _navigateToSubjectDetails(int subjectId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subject details for ID: $subjectId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToEditAttendance(int subjectId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit attendance for subject ID: $subjectId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSubjectSettings(int subjectId) {
    Navigator.pushNamed(context, '/add-edit-subject');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Dashboard',
        variant: CustomAppBarVariant.standard,
        showBackButton: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(4.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Greeting Header
                    GreetingHeaderWidget(
                      userName: _userName,
                      currentDate: _currentDate,
                      overallAttendancePercentage: _overallAttendancePercentage,
                    ),
                    SizedBox(height: 3.h),
                    
                    // Attendance Summary
                    AttendanceSummaryWidget(
                      totalLectures: _totalLectures,
                      attendedLectures: _totalAttendedLectures,
                      attendancePercentage: _overallAttendancePercentage,
                      lecturesCanBunk: _lecturesCanBunk,
                      subjectsBelowThreshold: _subjectsBelowThreshold,
                    ),
                    SizedBox(height: 3.h),
                    
                    // Today's Schedule Header
                    if (_mockSubjects.isNotEmpty) ...[
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'today',
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Today\'s Schedule',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_mockSubjects.length} ${_mockSubjects.length == 1 ? 'class' : 'classes'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ]),
                ),
              ),
              
              // Today's Subjects or Empty State
              _mockSubjects.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final subject = _mockSubjects[index];
                          return TodaySubjectCardWidget(
                            subject: subject,
                            onMarkPresent: () => _markAttendance(subject['id'] as int, true),
                            onMarkAbsent: () => _markAttendance(subject['id'] as int, false),
                            onViewDetails: () => _navigateToSubjectDetails(subject['id'] as int),
                            onEditAttendance: () => _navigateToEditAttendance(subject['id'] as int),
                            onSubjectSettings: () => _navigateToSubjectSettings(subject['id'] as int),
                          );
                        },
                        childCount: _mockSubjects.length,
                      ),
                    )
                  : SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        onMarkAttendancePressed: _navigateToManualAttendance,
                      ),
                    ),
              
              // Bottom padding
              SliverPadding(
                padding: EdgeInsets.only(bottom: 10.h),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _mockSubjects.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToManualAttendance,
              icon: CustomIconWidget(
                iconName: 'edit_calendar',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Manual Entry'),
              tooltip: 'Mark attendance for other dates',
            )
          : null,
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 0,
        onTap: _handleBottomNavigation,
      ),
    );
  }

  static void _handleBottomNavigation(int index) {
    // Navigation handled by CustomBottomBar
  }
}