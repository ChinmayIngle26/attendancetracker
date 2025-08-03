import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AddSubjectBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubjectAdded;

  const AddSubjectBottomSheet({
    super.key,
    required this.onSubjectAdded,
  });

  @override
  State<AddSubjectBottomSheet> createState() => _AddSubjectBottomSheetState();
}

class _AddSubjectBottomSheetState extends State<AddSubjectBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColor = 0xFF2E7D32;
  String _selectedIcon = 'book';

  final List<int> _colors = [
    0xFF2E7D32, // Green
    0xFF1565C0, // Blue
    0xFFD32F2F, // Red
    0xFFFF6F00, // Orange
    0xFF7B1FA2, // Purple
    0xFF388E3C, // Light Green
    0xFF1976D2, // Light Blue
    0xFFE64A19, // Deep Orange
    0xFF5D4037, // Brown
    0xFF455A64, // Blue Grey
    0xFFC2185B, // Pink
    0xFF00796B, // Teal
  ];

  final List<String> _icons = [
    'book',
    'science',
    'calculate',
    'computer',
    'language',
    'history_edu',
    'psychology',
    'biotech',
    'functions',
    'public',
    'palette',
    'sports_soccer',
    'music_note',
    'theater_comedy',
    'business',
    'engineering',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addSubject() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a subject name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newSubject = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'color': _selectedColor,
      'icon': _selectedIcon,
      'totalLectures': 0,
      'attendedLectures': 0,
      'createdAt': DateTime.now(),
      'lastUpdated': DateTime.now(),
    };

    widget.onSubjectAdded(newSubject);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 6.w,
          right: 6.w,
          top: 3.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 3.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Subject',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 6.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Subject Name',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter subject name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 3.h),
            Text(
              'Choose Color',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(
              height: 8.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = color == _selectedColor;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      margin: EdgeInsets.only(right: 3.w),
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? Center(
                              child: CustomIconWidget(
                                iconName: 'check',
                                color: Colors.white,
                                size: 5.w,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Choose Icon',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(
              height: 8.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = icon == _selectedIcon;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      margin: EdgeInsets.only(right: 3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_selectedColor).withValues(alpha: 0.2)
                            : theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Color(_selectedColor)
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: icon,
                          color: isSelected
                              ? Color(_selectedColor)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 6.w,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addSubject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Subject',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
