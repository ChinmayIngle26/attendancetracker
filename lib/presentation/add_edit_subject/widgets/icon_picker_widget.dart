import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class IconPickerWidget extends StatelessWidget {
  final String selectedIcon;
  final Function(String) onIconSelected;
  final Color selectedColor;

  const IconPickerWidget({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Icon',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 15.h,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            itemCount: _academicIcons.length,
            itemBuilder: (context, index) {
              final iconData = _academicIcons[index];
              final isSelected = iconData['name'] == selectedIcon;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onIconSelected(iconData['name'] as String);
                },
                child: Container(
                  width: 15.w,
                  margin: EdgeInsets.only(right: 3.w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: iconData['name'] as String,
                          color: isSelected
                              ? selectedColor
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 28,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          iconData['label'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? selectedColor
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: selectedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: selectedIcon,
                  color: _getContrastColor(selectedColor),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Selected Icon',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static const List<Map<String, String>> _academicIcons = [
    {'name': 'book', 'label': 'Book'},
    {'name': 'school', 'label': 'School'},
    {'name': 'science', 'label': 'Science'},
    {'name': 'calculate', 'label': 'Math'},
    {'name': 'language', 'label': 'Language'},
    {'name': 'history', 'label': 'History'},
    {'name': 'psychology', 'label': 'Psychology'},
    {'name': 'biotech', 'label': 'Biology'},
    {'name': 'functions', 'label': 'Functions'},
    {'name': 'auto_stories', 'label': 'Literature'},
    {'name': 'public', 'label': 'Geography'},
    {'name': 'palette', 'label': 'Art'},
    {'name': 'music_note', 'label': 'Music'},
    {'name': 'sports', 'label': 'Sports'},
    {'name': 'computer', 'label': 'Computer'},
    {'name': 'engineering', 'label': 'Engineering'},
    {'name': 'business', 'label': 'Business'},
    {'name': 'account_balance', 'label': 'Economics'},
    {'name': 'gavel', 'label': 'Law'},
    {'name': 'medical_services', 'label': 'Medicine'},
    {'name': 'architecture', 'label': 'Architecture'},
    {'name': 'design_services', 'label': 'Design'},
    {'name': 'camera', 'label': 'Photography'},
    {'name': 'theater_comedy', 'label': 'Drama'},
    {'name': 'translate', 'label': 'Translation'},
  ];
}