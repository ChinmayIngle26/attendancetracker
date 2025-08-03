import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/color_picker_widget.dart';
import './widgets/icon_picker_widget.dart';
import './widgets/subject_form_widget.dart';

class AddEditSubject extends StatefulWidget {
  const AddEditSubject({super.key});

  @override
  State<AddEditSubject> createState() => _AddEditSubjectState();
}

class _AddEditSubjectState extends State<AddEditSubject> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _instructorController = TextEditingController();
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();

  Color _selectedColor = const Color(0xFF2196F3);
  String _selectedIcon = 'book';
  int _targetAttendance = 75;
  bool _isEditing = false;
  int? _subjectId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubjectData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadSubjectData() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is int) {
      setState(() {
        _isEditing = true;
        _subjectId = arguments;
        // Load subject data for editing
        _loadExistingSubjectData(_subjectId!);
      });
    }
  }

  void _loadExistingSubjectData(int subjectId) {
    // Mock data loading - in real app, load from database
    _nameController.text = 'Mathematics';
    _codeController.text = 'MATH101';
    _instructorController.text = 'Dr. Smith';
    _roomController.text = 'A-101';
    _notesController.text = 'Advanced calculus course';
    _selectedColor = const Color(0xFF2196F3);
    _selectedIcon = 'calculate';
    _targetAttendance = 75;
  }

  void _saveSubject() {
    if (_formKey.currentState!.validate()) {
      // Save subject logic here

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing
              ? 'Subject updated successfully'
              : 'Subject created successfully'),
          behavior: SnackBarBehavior.floating));

      // Navigate back to subject management
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.subjectManagement, (route) => false);
    }
  }

  void _cancelEdit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Discard Changes'),
                content: const Text(
                    'Are you sure you want to discard your changes?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Continue Editing')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(context,
                            AppRoutes.subjectManagement, (route) => false);
                      },
                      child: const Text('Discard')),
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
            title: _isEditing ? 'Edit Subject' : 'Add Subject',
            variant: CustomAppBarVariant.standard,
            showBackButton: true,
            onBackPressed: _cancelEdit,
            actions: [
              TextButton(
                  onPressed: _saveSubject,
                  child: Text('Save',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600))),
            ]),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subject Preview Card
                          Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                  color: _selectedColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          _selectedColor.withValues(alpha: 0.3),
                                      width: 2)),
                              child: Row(children: [
                                Container(
                                    width: 15.w,
                                    height: 15.w,
                                    decoration: BoxDecoration(
                                        color: _selectedColor,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Center(
                                        child: CustomIconWidget(
                                            iconName: _selectedIcon,
                                            color: Colors.white,
                                            size: 8.w))),
                                SizedBox(width: 4.w),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                          _nameController.text.isEmpty
                                              ? 'Subject Name'
                                              : _nameController.text,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedColor)),
                                      if (_codeController.text.isNotEmpty)
                                        Text(_codeController.text,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withValues(
                                                            alpha: 0.7))),
                                    ])),
                              ])),
                          SizedBox(height: 4.h),

                          // Subject Form
                          SubjectFormWidget(
                              nameController: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a subject name';
                                }
                                return null;
                              }),
                          SizedBox(height: 4.h),

                          // Color Picker
                          ColorPickerWidget(
                              selectedColor: _selectedColor,
                              onColorSelected: (color) {
                                setState(() {
                                  _selectedColor = color;
                                });
                              }),
                          SizedBox(height: 4.h),

                          // Icon Picker
                          IconPickerWidget(
                              selectedIcon: _selectedIcon,
                              selectedColor: _selectedColor,
                              onIconSelected: (icon) {
                                setState(() {
                                  _selectedIcon = icon;
                                });
                              }),
                          SizedBox(height: 6.h),
                        ])))));
  }
}