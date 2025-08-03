import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/attendance_chart.dart';
import './widgets/filter_options.dart';
import './widgets/overall_stats_card.dart';
import './widgets/subject_stats_card.dart';

class AttendanceStatistics extends StatefulWidget {
  const AttendanceStatistics({super.key});

  @override
  State<AttendanceStatistics> createState() => _AttendanceStatisticsState();
}

class _AttendanceStatisticsState extends State<AttendanceStatistics>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ViewMode _selectedViewMode = ViewMode.percentage;
  DateRange _selectedDateRange = DateRange.all;
  List<String> _selectedSubjects = [];
  List<String> _availableSubjects = [];
  ChartType _selectedChartType = ChartType.bar;
  bool _isFilterExpanded = false;

  // Mock data for attendance statistics
  final List<Map<String, dynamic>> _mockSubjects = [
    {
      "id": 1,
      "name": "Data Structures",
      "color": 0xFF2E7D32,
      "totalLectures": 45,
      "attendedLectures": 38,
      "icon": "code",
      "recentAttendance": [
        {"date": "2025-08-01", "status": "present"},
        {"date": "2025-07-30", "status": "present"},
        {"date": "2025-07-28", "status": "absent"},
        {"date": "2025-07-26", "status": "present"},
        {"date": "2025-07-24", "status": "present"},
      ],
    },
    {
      "id": 2,
      "name": "Database Management",
      "color": 0xFF1565C0,
      "totalLectures": 40,
      "attendedLectures": 28,
      "icon": "storage",
      "recentAttendance": [
        {"date": "2025-08-02", "status": "absent"},
        {"date": "2025-07-31", "status": "present"},
        {"date": "2025-07-29", "status": "absent"},
        {"date": "2025-07-27", "status": "present"},
        {"date": "2025-07-25", "status": "absent"},
      ],
    },
    {
      "id": 3,
      "name": "Computer Networks",
      "color": 0xFFD32F2F,
      "totalLectures": 38,
      "attendedLectures": 30,
      "icon": "network_check",
      "recentAttendance": [
        {"date": "2025-08-03", "status": "present"},
        {"date": "2025-08-01", "status": "present"},
        {"date": "2025-07-30", "status": "present"},
        {"date": "2025-07-28", "status": "absent"},
        {"date": "2025-07-26", "status": "present"},
      ],
    },
    {
      "id": 4,
      "name": "Software Engineering",
      "color": 0xFF388E3C,
      "totalLectures": 42,
      "attendedLectures": 35,
      "icon": "engineering",
      "recentAttendance": [
        {"date": "2025-08-02", "status": "present"},
        {"date": "2025-07-31", "status": "present"},
        {"date": "2025-07-29", "status": "present"},
        {"date": "2025-07-27", "status": "absent"},
        {"date": "2025-07-25", "status": "present"},
      ],
    },
    {
      "id": 5,
      "name": "Operating Systems",
      "color": 0xFFF57C00,
      "totalLectures": 36,
      "attendedLectures": 25,
      "icon": "computer",
      "recentAttendance": [
        {"date": "2025-08-03", "status": "absent"},
        {"date": "2025-08-01", "status": "present"},
        {"date": "2025-07-30", "status": "absent"},
        {"date": "2025-07-28", "status": "present"},
        {"date": "2025-07-26", "status": "absent"},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _availableSubjects =
        (_mockSubjects.map((subject) => subject['name'] as String).toList());
    _selectedSubjects = List.from(_availableSubjects);
  }

  double _calculateOverallPercentage() {
    if (_mockSubjects.isEmpty) return 0.0;

    int totalLectures = 0;
    int totalAttended = 0;

    for (final subject in _mockSubjects) {
      if (_selectedSubjects.contains(subject['name'])) {
        totalLectures += subject['totalLectures'] as int;
        totalAttended += subject['attendedLectures'] as int;
      }
    }

    return totalLectures > 0 ? (totalAttended / totalLectures) * 100 : 0.0;
  }

  int _getTotalLectures() {
    return _mockSubjects
        .where((subject) => _selectedSubjects.contains(subject['name']))
        .fold(0, (sum, subject) => sum + (subject['totalLectures'] as int));
  }

  int _getTotalAttended() {
    return _mockSubjects
        .where((subject) => _selectedSubjects.contains(subject['name']))
        .fold(0, (sum, subject) => sum + (subject['attendedLectures'] as int));
  }

  List<Map<String, dynamic>> _getFilteredSubjects() {
    return _mockSubjects
        .where((subject) => _selectedSubjects.contains(subject['name']))
        .toList();
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Data would be refreshed from storage here
    });
  }

  void _exportData() async {
    try {
      final csvData = _generateCSVData();
      final fileName =
          'attendance_statistics_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile platforms, you would use path_provider and file operations
        // This is a simplified version
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export functionality would save to: $fileName'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance data exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateCSVData() {
    final buffer = StringBuffer();
    buffer
        .writeln('Subject,Total Lectures,Attended Lectures,Percentage,Status');

    for (final subject in _getFilteredSubjects()) {
      final name = subject['name'];
      final total = subject['totalLectures'];
      final attended = subject['attendedLectures'];
      final percentage = total > 0 ? (attended / total) * 100 : 0.0;
      final status = percentage >= 75 ? 'Good' : 'Below Threshold';

      buffer.writeln(
          '$name,$total,$attended,${percentage.toStringAsFixed(2)}%,$status');
    }

    return buffer.toString();
  }

  void _showAdjustAttendanceDialog(Map<String, dynamic> subject) {
    final TextEditingController totalController = TextEditingController(
      text: (subject['totalLectures'] as int).toString(),
    );
    final TextEditingController attendedController = TextEditingController(
      text: (subject['attendedLectures'] as int).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subject['name'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Lectures',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: attendedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Attended Lectures',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final total = int.tryParse(totalController.text) ?? 0;
              final attended = int.tryParse(attendedController.text) ?? 0;

              if (attended <= total) {
                setState(() {
                  subject['totalLectures'] = total;
                  subject['attendedLectures'] = attended;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Attended lectures cannot exceed total lectures'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance Statistics',
        variant: CustomAppBarVariant.withActions,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            icon: CustomIconWidget(
              iconName: _isFilterExpanded ? 'filter_list_off' : 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Toggle Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterExpanded)
            FilterOptions(
              selectedViewMode: _selectedViewMode,
              selectedDateRange: _selectedDateRange,
              selectedSubjects: _selectedSubjects,
              availableSubjects: _availableSubjects,
              onViewModeChanged: (mode) {
                setState(() {
                  _selectedViewMode = mode;
                });
              },
              onDateRangeChanged: (range) {
                setState(() {
                  _selectedDateRange = range;
                });
              },
              onSubjectsChanged: (subjects) {
                setState(() {
                  _selectedSubjects = subjects;
                });
              },
              onExport: _exportData,
            ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Subjects'),
                    Tab(text: 'Charts'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildSubjectsTab(),
                      _buildChartsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3,
        onTap: (index) {},
        variant: CustomBottomBarVariant.adaptive,
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            OverallStatsCard(
              overallPercentage: _calculateOverallPercentage(),
              totalLectures: _getTotalLectures(),
              attendedLectures: _getTotalAttended(),
              totalSubjects: _selectedSubjects.length,
            ),
            SizedBox(height: 2.h),
            _buildQuickStats(),
            SizedBox(height: 2.h),
            _buildCriticalSubjects(),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsTab() {
    final filteredSubjects = _getFilteredSubjects();

    if (filteredSubjects.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: filteredSubjects.length,
        itemBuilder: (context, index) {
          final subject = filteredSubjects[index];
          return SubjectStatsCard(
            subject: subject,
            onTap: () {
              // Navigate to detailed subject view
              Navigator.pushNamed(context, '/manual-attendance-entry');
            },
            onAdjustAttendance: () => _showAdjustAttendanceDialog(subject),
          );
        },
      ),
    );
  }

  Widget _buildChartsTab() {
    final filteredSubjects = _getFilteredSubjects();

    if (filteredSubjects.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          AttendanceChart(
            chartData: filteredSubjects,
            chartType: _selectedChartType,
            title: 'Subject-wise Attendance',
            onChartTypeChanged: (type) {
              setState(() {
                _selectedChartType = type;
              });
            },
          ),
          SizedBox(height: 2.h),
          _buildMonthlyTrendChart(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final theme = Theme.of(context);
    final criticalSubjects = _getFilteredSubjects().where((subject) {
      final total = subject['totalLectures'] as int;
      final attended = subject['attendedLectures'] as int;
      final percentage = total > 0 ? (attended / total) * 100 : 0.0;
      return percentage < 75;
    }).length;

    final goodSubjects = _selectedSubjects.length - criticalSubjects;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStatCard(
              context,
              'Good Standing',
              goodSubjects.toString(),
              CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.tertiary,
                size: 24,
              ),
              theme.colorScheme.tertiary,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildQuickStatCard(
              context,
              'Critical',
              criticalSubjects.toString(),
              CustomIconWidget(
                iconName: 'warning',
                color: theme.colorScheme.error,
                size: 24,
              ),
              theme.colorScheme.error,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildQuickStatCard(
              context,
              'Average',
              '${_calculateOverallPercentage().toStringAsFixed(1)}%',
              CustomIconWidget(
                iconName: 'analytics',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String title,
    String value,
    Widget icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
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
          icon,
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalSubjects() {
    final theme = Theme.of(context);
    final criticalSubjects = _getFilteredSubjects().where((subject) {
      final total = subject['totalLectures'] as int;
      final attended = subject['attendedLectures'] as int;
      final percentage = total > 0 ? (attended / total) * 100 : 0.0;
      return percentage < 75;
    }).toList();

    if (criticalSubjects.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: theme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Great Job!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'All selected subjects are above 75% attendance threshold.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Critical Subjects (Below 75%)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(height: 1.h),
          ...criticalSubjects.map((subject) {
            final total = subject['totalLectures'] as int;
            final attended = subject['attendedLectures'] as int;
            final percentage = total > 0 ? (attended / total) * 100 : 0.0;

            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
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
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$attended/$total lectures (${percentage.toStringAsFixed(1)}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendChart() {
    final theme = Theme.of(context);

    // Mock monthly trend data
    final monthlyData = [
      {"month": "Jan", "percentage": 82.5},
      {"month": "Feb", "percentage": 78.3},
      {"month": "Mar", "percentage": 85.1},
      {"month": "Apr", "percentage": 79.8},
      {"month": "May", "percentage": 83.2},
      {"month": "Jun", "percentage": 77.6},
      {"month": "Jul", "percentage": 81.4},
      {"month": "Aug", "percentage": _calculateOverallPercentage()},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
            'Monthly Attendance Trend',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 25.h,
            child: Center(
              child: Text(
                'Monthly trend chart would be displayed here with real data visualization',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'analytics',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Data Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Start marking attendance to see your statistics here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard-home');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Mark Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
