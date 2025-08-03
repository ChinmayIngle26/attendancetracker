import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/add_subject_bottom_sheet.dart';
import './widgets/empty_state_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_dropdown_widget.dart';
import './widgets/subject_card_widget.dart';
import './widgets/view_toggle_widget.dart';

class SubjectManagement extends StatefulWidget {
  const SubjectManagement({super.key});

  @override
  State<SubjectManagement> createState() => _SubjectManagementState();
}

class _SubjectManagementState extends State<SubjectManagement>
    with TickerProviderStateMixin {
  ViewType _currentView = ViewType.list;
  SortType _currentSort = SortType.alphabetical;
  String _searchQuery = '';
  bool _isEditMode = false;
  final Set<int> _selectedSubjects = {};
  late ScrollController _scrollController;
  bool _isSearchCollapsed = false;

  // Mock data for subjects
  List<Map<String, dynamic>> _subjects = [
    {
      'id': 1,
      'name': 'Mathematics',
      'color': 0xFF2E7D32,
      'icon': 'calculate',
      'totalLectures': 45,
      'attendedLectures': 38,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'lastUpdated': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 2,
      'name': 'Physics',
      'color': 0xFF1565C0,
      'icon': 'science',
      'totalLectures': 40,
      'attendedLectures': 28,
      'createdAt': DateTime.now().subtract(const Duration(days: 25)),
      'lastUpdated': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 3,
      'name': 'Computer Science',
      'color': 0xFFD32F2F,
      'icon': 'computer',
      'totalLectures': 50,
      'attendedLectures': 42,
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
      'lastUpdated': DateTime.now(),
    },
    {
      'id': 4,
      'name': 'English Literature',
      'color': 0xFF7B1FA2,
      'icon': 'book',
      'totalLectures': 35,
      'attendedLectures': 20,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      'lastUpdated': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 5,
      'name': 'Chemistry',
      'color': 0xFF388E3C,
      'icon': 'biotech',
      'totalLectures': 42,
      'attendedLectures': 35,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 5)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isSearchCollapsed) {
      setState(() {
        _isSearchCollapsed = true;
      });
    } else if (_scrollController.offset <= 100 && _isSearchCollapsed) {
      setState(() {
        _isSearchCollapsed = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedSubjects {
    List<Map<String, dynamic>> filtered = _subjects;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((subject) {
        return (subject['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortType.alphabetical:
        filtered.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case SortType.mostActive:
        filtered.sort((a, b) {
          final aLastUpdated = a['lastUpdated'] as DateTime;
          final bLastUpdated = b['lastUpdated'] as DateTime;
          return bLastUpdated.compareTo(aLastUpdated);
        });
        break;
      case SortType.attendancePercentage:
        filtered.sort((a, b) {
          final aPercentage = (a['attendedLectures'] as int) /
              (a['totalLectures'] as int > 0 ? a['totalLectures'] as int : 1);
          final bPercentage = (b['attendedLectures'] as int) /
              (b['totalLectures'] as int > 0 ? b['totalLectures'] as int : 1);
          return bPercentage.compareTo(aPercentage);
        });
        break;
    }

    return filtered;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedSubjects.clear();
      }
    });
  }

  void _selectSubject(int subjectId) {
    setState(() {
      if (_selectedSubjects.contains(subjectId)) {
        _selectedSubjects.remove(subjectId);
      } else {
        _selectedSubjects.add(subjectId);
      }
    });
  }

  void _deleteSelectedSubjects() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subjects'),
        content: Text(
          'Are you sure you want to delete ${_selectedSubjects.length} subject(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _subjects.removeWhere((subject) =>
                    _selectedSubjects.contains(subject['id'] as int));
                _selectedSubjects.clear();
                _isEditMode = false;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subjects deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateSubject(Map<String, dynamic> subject) {
    final duplicatedSubject = Map<String, dynamic>.from(subject);
    duplicatedSubject['id'] = DateTime.now().millisecondsSinceEpoch;
    duplicatedSubject['name'] = '${subject['name']} (Copy)';
    duplicatedSubject['createdAt'] = DateTime.now();
    duplicatedSubject['lastUpdated'] = DateTime.now();
    duplicatedSubject['totalLectures'] = 0;
    duplicatedSubject['attendedLectures'] = 0;

    setState(() {
      _subjects.add(duplicatedSubject);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subject duplicated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteSubject(Map<String, dynamic> subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _subjects.removeWhere((s) => s['id'] == subject['id']);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subject deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSubjectContextMenu(Map<String, dynamic> subject) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Edit Subject'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/add-edit-subject');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Duplicate Subject'),
              onTap: () {
                Navigator.of(context).pop();
                _duplicateSubject(subject);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 6.w,
              ),
              title: const Text('Delete Subject'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteSubject(subject);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addSubject(Map<String, dynamic> newSubject) {
    setState(() {
      _subjects.add(newSubject);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subject added successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddSubjectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubjectBottomSheet(
        onSubjectAdded: _addSubject,
      ),
    );
  }

  Future<void> _refreshSubjects() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Recalculate statistics and update last updated time
    setState(() {
      for (var subject in _subjects) {
        subject['lastUpdated'] = DateTime.now();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subjects refreshed'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSubjects = _filteredAndSortedSubjects;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? '${_selectedSubjects.length} Selected'
              : 'Subject Management',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: _isEditMode
            ? IconButton(
                onPressed: _toggleEditMode,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurface,
                  size: 6.w,
                ),
              )
            : IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/dashboard-home'),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: theme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
        actions: [
          if (_isEditMode && _selectedSubjects.isNotEmpty)
            IconButton(
              onPressed: _deleteSelectedSubjects,
              icon: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 6.w,
              ),
            )
          else if (!_isEditMode && _subjects.isNotEmpty)
            IconButton(
              onPressed: _toggleEditMode,
              icon: CustomIconWidget(
                iconName: 'edit',
                color: theme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
        ],
      ),
      body: _subjects.isEmpty
          ? EmptyStateWidget(onAddSubject: _showAddSubjectBottomSheet)
          : Column(
              children: [
                // Header with controls
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      if (!_isEditMode) ...[
                        SearchBarWidget(
                          searchQuery: _searchQuery,
                          onSearchChanged: (query) {
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                          isCollapsed: _isSearchCollapsed,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ViewToggleWidget(
                              currentView: _currentView,
                              onViewChanged: (view) {
                                setState(() {
                                  _currentView = view;
                                });
                              },
                            ),
                            SortDropdownWidget(
                              currentSort: _currentSort,
                              onSortChanged: (sort) {
                                setState(() {
                                  _currentSort = sort;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Subject list/grid
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshSubjects,
                    child: filteredSubjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'search_off',
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  size: 15.w,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No subjects found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _currentView == ViewType.grid
                            ? GridView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(2.w),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 2.w,
                                  mainAxisSpacing: 2.w,
                                ),
                                itemCount: filteredSubjects.length,
                                itemBuilder: (context, index) {
                                  final subject = filteredSubjects[index];
                                  final subjectId = subject['id'] as int;

                                  return SubjectCardWidget(
                                    subject: subject,
                                    isGridView: true,
                                    isSelected:
                                        _selectedSubjects.contains(subjectId),
                                    isEditMode: _isEditMode,
                                    onTap: () {
                                      if (_isEditMode) {
                                        _selectSubject(subjectId);
                                      } else {
                                        Navigator.pushNamed(
                                            context, '/add-edit-subject');
                                      }
                                    },
                                    onLongPress: () {
                                      if (!_isEditMode) {
                                        _showSubjectContextMenu(subject);
                                      }
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                itemCount: filteredSubjects.length,
                                itemBuilder: (context, index) {
                                  final subject = filteredSubjects[index];
                                  final subjectId = subject['id'] as int;

                                  return Dismissible(
                                    key: Key(subjectId.toString()),
                                    direction: _isEditMode
                                        ? DismissDirection.none
                                        : DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(right: 6.w),
                                      color: theme.colorScheme.error,
                                      child: CustomIconWidget(
                                        iconName: 'delete',
                                        color: theme.colorScheme.onError,
                                        size: 6.w,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      return await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Subject'),
                                          content: Text(
                                            'Are you sure you want to delete "${subject['name']}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    onDismissed: (direction) {
                                      setState(() {
                                        _subjects.removeWhere(
                                            (s) => s['id'] == subjectId);
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${subject['name']} deleted'),
                                          behavior: SnackBarBehavior.floating,
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () {
                                              setState(() {
                                                _subjects.add(subject);
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: SubjectCardWidget(
                                      subject: subject,
                                      isGridView: false,
                                      isSelected:
                                          _selectedSubjects.contains(subjectId),
                                      isEditMode: _isEditMode,
                                      onTap: () {
                                        if (_isEditMode) {
                                          _selectSubject(subjectId);
                                        } else {
                                          Navigator.pushNamed(
                                              context, '/add-edit-subject');
                                        }
                                      },
                                      onLongPress: () {
                                        if (!_isEditMode) {
                                          _showSubjectContextMenu(subject);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _isEditMode
          ? null
          : FloatingActionButton(
              onPressed: _showAddSubjectBottomSheet,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 6.w,
              ),
            ),
    );
  }
}
