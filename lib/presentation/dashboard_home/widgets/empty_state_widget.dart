import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onMarkAttendancePressed;

  const EmptyStateWidget({
    super.key,
    required this.onMarkAttendancePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'free_breakfast',
                color: theme.colorScheme.primary,
                size: 48,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No Classes Today!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Enjoy your free day! You can still mark attendance for other dates or review your progress.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          _buildMotivationalQuote(theme),
          SizedBox(height: 4.h),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote(ThemeData theme) {
    final quotes = [
      {
        'text':
            'Success is the sum of small efforts repeated day in and day out.',
        'author': 'Robert Collier'
      },
      {
        'text':
            'The future belongs to those who believe in the beauty of their dreams.',
        'author': 'Eleanor Roosevelt'
      },
      {
        'text':
            'Education is the most powerful weapon which you can use to change the world.',
        'author': 'Nelson Mandela'
      },
      {
        'text': 'The only way to do great work is to love what you do.',
        'author': 'Steve Jobs'
      },
    ];

    final selectedQuote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'format_quote',
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            selectedQuote['text']!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            '— ${selectedQuote['author']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onMarkAttendancePressed,
            icon: CustomIconWidget(
              iconName: 'edit_calendar',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            label: const Text('Mark Attendance for Other Dates'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to statistics - feature coming soon
                },
                icon: CustomIconWidget(
                  iconName: 'analytics',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: const Text('View Stats'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to subjects - feature coming soon
                },
                icon: CustomIconWidget(
                  iconName: 'subject',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: const Text('Subjects'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}