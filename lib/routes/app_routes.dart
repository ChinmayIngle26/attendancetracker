import 'package:flutter/material.dart';
import '../presentation/add_edit_subject/add_edit_subject.dart';
import '../presentation/attendance_statistics/attendance_statistics.dart';
import '../presentation/subject_management/subject_management.dart';
import '../presentation/timetable_management/timetable_management.dart';
import '../presentation/manual_attendance_entry/manual_attendance_entry.dart';
import '../presentation/dashboard_home/dashboard_home.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String addEditSubject = '/add-edit-subject';
  static const String attendanceStatistics = '/attendance-statistics';
  static const String subjectManagement = '/subject-management';
  static const String timetableManagement = '/timetable-management';
  static const String manualAttendanceEntry = '/manual-attendance-entry';
  static const String dashboardHome = '/dashboard-home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const AddEditSubject(),
    addEditSubject: (context) => const AddEditSubject(),
    attendanceStatistics: (context) => const AttendanceStatistics(),
    subjectManagement: (context) => const SubjectManagement(),
    timetableManagement: (context) => const TimetableManagement(),
    manualAttendanceEntry: (context) => const ManualAttendanceEntry(),
    dashboardHome: (context) => const DashboardHome(),
    // TODO: Add your other routes here
  };
}
