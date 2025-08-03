import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ColorPickerWidget extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Color',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _academicColors.length,
            itemBuilder: (context, index) {
              final color = _academicColors[index];
              final isSelected = color.value == selectedColor.value;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onColorSelected(color);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: isSelected ? 3 : 0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: theme.colorScheme.shadow
                                  .withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: isSelected
                      ? Center(
                          child: CustomIconWidget(
                            iconName: 'check',
                            color: _getContrastColor(color),
                            size: 20,
                          ),
                        )
                      : null,
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
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Selected Color',
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

  static const List<Color> _academicColors = [
    // Primary academic colors
    Color(0xFF2E7D32), // Deep Green
    Color(0xFF1565C0), // Rich Blue
    Color(0xFF7B1FA2), // Deep Purple
    Color(0xFFD32F2F), // Academic Red

    // Secondary academic colors
    Color(0xFF388E3C), // Forest Green
    Color(0xFF1976D2), // Blue
    Color(0xFF8E24AA), // Purple
    Color(0xFFE53935), // Red

    // Tertiary academic colors
    Color(0xFF00796B), // Teal
    Color(0xFF5D4037), // Brown
    Color(0xFFFF6F00), // Deep Orange
    Color(0xFF455A64), // Blue Grey

    // Lighter academic colors
    Color(0xFF43A047), // Light Green
    Color(0xFF1E88E5), // Light Blue
    Color(0xFF8E24AA), // Medium Purple
    Color(0xFFFF5722), // Deep Orange Red

    // Professional colors
    Color(0xFF37474F), // Dark Grey
    Color(0xFF6A1B9A), // Deep Purple
    Color(0xFF00838F), // Dark Cyan
    Color(0xFFBF360C), // Deep Orange
  ];
}
