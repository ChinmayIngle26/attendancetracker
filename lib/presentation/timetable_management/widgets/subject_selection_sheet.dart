import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SubjectSelectionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final Function(int subjectId, String? room) onSubjectSelected;
  final Map<String, dynamic>? existingEntry;

  const SubjectSelectionSheet({
    super.key,
    required this.subjects,
    required this.onSubjectSelected,
    this.existingEntry,
  });

  @override
  State<SubjectSelectionSheet> createState() => _SubjectSelectionSheetState();
}

class _SubjectSelectionSheetState extends State<SubjectSelectionSheet> {
  int? selectedSubjectId;
  final TextEditingController _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      selectedSubjectId = widget.existingEntry!['subjectId'] as int?;
      _roomController.text = widget.existingEntry!['room'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildSubjectList(context),
          _buildRoomInput(context),
          _buildActionButtons(context),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.existingEntry != null ? 'Edit Class' : 'Add Class',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: 40.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.subjects.length,
        itemBuilder: (context, index) {
          final subject = widget.subjects[index];
          final isSelected = selectedSubjectId == subject['id'];
          final subjectColor = Color(int.parse(
              (subject['color'] as String).replaceFirst('#', '0xFF')));

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: () {
                setState(() {
                  selectedSubjectId = subject['id'] as int;
                });
              },
              leading: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: subjectColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: subject['icon'] != null
                      ? CustomIconWidget(
                          iconName: subject['icon'] as String,
                          color: subjectColor,
                          size: 20,
                        )
                      : Text(
                          (subject['abbreviation'] as String? ?? 'S')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: subjectColor,
                          ),
                        ),
                ),
              ),
              title: Text(
                subject['name'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                subject['abbreviation'] as String? ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              trailing: isSelected
                  ? CustomIconWidget(
                      iconName: 'check_circle',
                      color: theme.colorScheme.primary,
                      size: 24,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomInput(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: TextField(
        controller: _roomController,
        decoration: InputDecoration(
          labelText: 'Room/Location (Optional)',
          hintText: 'e.g., A101, Lab 1, Online',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'location_on',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        textCapitalization: TextCapitalization.words,
        maxLength: 20,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedSubjectId != null
                  ? () {
                      widget.onSubjectSelected(
                        selectedSubjectId!,
                        _roomController.text.trim().isEmpty
                            ? null
                            : _roomController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.existingEntry != null ? 'Update' : 'Add Class',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
