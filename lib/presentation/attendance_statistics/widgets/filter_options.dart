import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum ViewMode { percentage, absolute, trends }

enum DateRange { week, month, semester, all }

class FilterOptions extends StatelessWidget {
  final ViewMode selectedViewMode;
  final DateRange selectedDateRange;
  final List<String> selectedSubjects;
  final List<String> availableSubjects;
  final Function(ViewMode) onViewModeChanged;
  final Function(DateRange) onDateRangeChanged;
  final Function(List<String>) onSubjectsChanged;
  final VoidCallback onExport;

  const FilterOptions({
    super.key,
    required this.selectedViewMode,
    required this.selectedDateRange,
    required this.selectedSubjects,
    required this.availableSubjects,
    required this.onViewModeChanged,
    required this.onDateRangeChanged,
    required this.onSubjectsChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filters & Options',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onExport,
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                tooltip: 'Export Data',
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildViewModeSelector(context, theme),
          SizedBox(height: 2.h),
          _buildDateRangeSelector(context, theme),
          SizedBox(height: 2.h),
          _buildSubjectFilter(context, theme),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'View Mode',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: ViewMode.values.map((mode) {
            final isSelected = selectedViewMode == mode;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: mode != ViewMode.values.last ? 2.w : 0),
                child: InkWell(
                  onTap: () => onViewModeChanged(mode),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: _getViewModeIcon(mode),
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _getViewModeLabel(mode),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 1.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: DateRange.values.map((range) {
              final isSelected = selectedDateRange == range;
              return Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: InkWell(
                  onTap: () => onDateRangeChanged(range),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getDateRangeLabel(range),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectFilter(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filter Subjects',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final allSelected =
                    selectedSubjects.length == availableSubjects.length;
                onSubjectsChanged(
                    allSelected ? [] : List.from(availableSubjects));
              },
              child: Text(
                selectedSubjects.length == availableSubjects.length
                    ? 'Clear All'
                    : 'Select All',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: availableSubjects.map((subject) {
            final isSelected = selectedSubjects.contains(subject);
            return InkWell(
              onTap: () {
                final newSelection = List<String>.from(selectedSubjects);
                if (isSelected) {
                  newSelection.remove(subject);
                } else {
                  newSelection.add(subject);
                }
                onSubjectsChanged(newSelection);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      CustomIconWidget(
                        iconName: 'check',
                        color: theme.colorScheme.primary,
                        size: 14,
                      ),
                    if (isSelected) SizedBox(width: 1.w),
                    Text(
                      subject,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getViewModeIcon(ViewMode mode) {
    switch (mode) {
      case ViewMode.percentage:
        return 'percent';
      case ViewMode.absolute:
        return 'numbers';
      case ViewMode.trends:
        return 'trending_up';
    }
  }

  String _getViewModeLabel(ViewMode mode) {
    switch (mode) {
      case ViewMode.percentage:
        return '%';
      case ViewMode.absolute:
        return '#';
      case ViewMode.trends:
        return 'Trend';
    }
  }

  String _getDateRangeLabel(DateRange range) {
    switch (range) {
      case DateRange.week:
        return 'This Week';
      case DateRange.month:
        return 'This Month';
      case DateRange.semester:
        return 'Semester';
      case DateRange.all:
        return 'All Time';
    }
  }
}
