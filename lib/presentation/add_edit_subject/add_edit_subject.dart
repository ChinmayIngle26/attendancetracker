import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/color_picker_widget.dart';
import './widgets/icon_picker_widget.dart';
import './widgets/subject_form_widget.dart';
import 'widgets/color_picker_widget.dart';
import 'widgets/icon_picker_widget.dart';
import 'widgets/subject_form_widget.dart';

class AddEditSubject extends StatefulWidget {
  final Map<String, dynamic>? existingSubject;

  const AddEditSubject({
    super.key,
    this.existingSubject,
  });

  @override
  State<AddEditSubject> createState() => _AddEditSubjectState();
}

class _AddEditSubjectState extends State<AddEditSubject>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Color _selectedColor = const Color(0xFF2E7D32);
  String _selectedIcon = 'book';
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock existing subjects for duplicate validation
  final List<Map<String, dynamic>> _existingSubjects = [
    {
      'id': 1,
      'name': 'Mathematics',
      'color': const Color(0xFF2E7D32),
      'icon': 'calculate',
      'totalLectures': 45,
      'attendedLectures': 38,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 2,
      'name': 'Physics',
      'color': const Color(0xFF1565C0),
      'icon': 'science',
      'totalLectures': 40,
      'attendedLectures': 35,
      'createdAt': DateTime.now().subtract(const Duration(days: 25)),
    },
    {
      'id': 3,
      'name': 'Chemistry',
      'color': const Color(0xFF7B1FA2),
      'icon': 'biotech',
      'totalLectures': 38,
      'attendedLectures': 32,
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSubjectData();
    _nameController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.removeListener(_onFormChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _initializeSubjectData() {
    if (widget.existingSubject != null) {
      final subject = widget.existingSubject!;
      _nameController.text = subject['name'] ?? '';
      _selectedColor = subject['color'] ?? const Color(0xFF2E7D32);
      _selectedIcon = subject['icon'] ?? 'book';
    }
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  bool get _isEditing => widget.existingSubject != null;

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _validateSubjectName(_nameController.text.trim()) == null;
  }

  String? _validateSubjectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Subject name must be at least 2 characters';
    }

    if (trimmedValue.length > 50) {
      return 'Subject name must be less than 50 characters';
    }

    // Check for duplicate names (excluding current subject if editing)
    final existingNames = _existingSubjects
        .where((subject) =>
            _isEditing ? subject['id'] != widget.existingSubject!['id'] : true)
        .map((subject) => (subject['name'] as String).toLowerCase())
        .toList();

    if (existingNames.contains(trimmedValue.toLowerCase())) {
      return 'A subject with this name already exists';
    }

    return null;
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1500));

      final subjectData = {
        'id': _isEditing
            ? widget.existingSubject!['id']
            : DateTime.now().millisecondsSinceEpoch,
        'name': _nameController.text.trim(),
        'color': _selectedColor,
        'icon': _selectedIcon,
        'totalLectures':
            _isEditing ? widget.existingSubject!['totalLectures'] : 0,
        'attendedLectures':
            _isEditing ? widget.existingSubject!['attendedLectures'] : 0,
        'createdAt':
            _isEditing ? widget.existingSubject!['createdAt'] : DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      // Simulate successful save
      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  _isEditing
                      ? 'Subject updated successfully!'
                      : 'Subject created successfully!',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(4.w),
          ),
        );

        // Navigate back with result
        Navigator.of(context).pop(subjectData);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                const Text('Failed to save subject. Please try again.'),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(4.w),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Edit Subject' : 'Add Subject',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 4.w),
              child: _isLoading
                  ? Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _isFormValid ? _saveSubject : null,
                      style: TextButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        foregroundColor: _isFormValid
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 1.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Update' : 'Save',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ],
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: _isEditing ? 'edit' : 'add',
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditing
                                      ? 'Edit Subject'
                                      : 'Create New Subject',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _isEditing
                                      ? 'Update subject details and preferences'
                                      : 'Add a new subject to track attendance',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Subject Form
                    SubjectFormWidget(
                      nameController: _nameController,
                      validator: _validateSubjectName,
                      onChanged: _onFormChanged,
                      isEditing: _isEditing,
                    ),

                    SizedBox(height: 4.h),

                    // Color Picker
                    ColorPickerWidget(
                      selectedColor: _selectedColor,
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Icon Picker
                    IconPickerWidget(
                      selectedIcon: _selectedIcon,
                      selectedColor: _selectedColor,
                      onIconSelected: (icon) {
                        setState(() {
                          _selectedIcon = icon;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Preview Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: _selectedColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _selectedColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: _selectedIcon,
                                    color: _getContrastColor(_selectedColor),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nameController.text.trim().isEmpty
                                            ? 'Subject Name'
                                            : _nameController.text.trim(),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _isEditing
                                            ? '${widget.existingSubject!['attendedLectures']}/${widget.existingSubject!['totalLectures']} lectures attended'
                                            : '0/0 lectures attended',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}