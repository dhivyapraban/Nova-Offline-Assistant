import 'package:flutter/material.dart';
import 'package:nova_assistant/core/theme/app_colors.dart';

/// Custom time picker dialog for creating/editing alarms
/// Allows selecting hour, minute, and optionally repeat days
class AlarmTimePicker extends StatefulWidget {
  final int? initialHour;
  final int? initialMinute;
  final String? initialLabel;
  final List<int>? initialRepeatDays;

  const AlarmTimePicker({
    super.key,
    this.initialHour,
    this.initialMinute,
    this.initialLabel,
    this.initialRepeatDays,
  });

  /// Shows the alarm time picker as a dialog and returns the result
  static Future<AlarmTimePickerResult?> show(
    BuildContext context, {
    int? initialHour,
    int? initialMinute,
    String? initialLabel,
    List<int>? initialRepeatDays,
  }) {
    return showDialog<AlarmTimePickerResult>(
      context: context,
      builder: (context) => AlarmTimePicker(
        initialHour: initialHour,
        initialMinute: initialMinute,
        initialLabel: initialLabel,
        initialRepeatDays: initialRepeatDays,
      ),
    );
  }

  @override
  State<AlarmTimePicker> createState() => _AlarmTimePickerState();
}

class _AlarmTimePickerState extends State<AlarmTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late TextEditingController _labelController;
  late List<int> _selectedDays;

  static const List<String> _dayLabels = [
    'S', 'M', 'T', 'W', 'T', 'F', 'S',
  ];
  static const List<String> _dayFullLabels = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
  ];

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _selectedHour = widget.initialHour ?? now.hour;
    _selectedMinute = widget.initialMinute ?? now.minute;
    _labelController = TextEditingController(text: widget.initialLabel ?? '');
    _selectedDays = List<int>.from(widget.initialRepeatDays ?? []);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
        _selectedDays.sort();
      }
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });
    }
  }

  String _formatTime() {
    final period = _selectedHour >= 12 ? 'PM' : 'AM';
    final displayHour = _selectedHour == 0
        ? 12
        : _selectedHour > 12
            ? _selectedHour - 12
            : _selectedHour;
    final displayMinute = _selectedMinute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              widget.initialHour != null ? 'Edit Alarm' : 'New Alarm',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Time display (tappable)
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? NovaColors.darkSurfaceVariant
                      : NovaColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: NovaColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _formatTime(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: NovaColors.primary,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change time',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? NovaColors.darkOnSurfaceVariant
                    : NovaColors.lightOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Label field
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: 'Label (optional)',
                prefixIcon: Icon(Icons.label_outline_rounded, size: 20),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Repeat days
            Text(
              'Repeat',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark
                    ? NovaColors.darkOnSurfaceVariant
                    : NovaColors.lightOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final isSelected = _selectedDays.contains(index);
                return Tooltip(
                  message: _dayFullLabels[index],
                  child: GestureDetector(
                    onTap: () => _toggleDay(index),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? NovaColors.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? NovaColors.primary
                              : (isDark
                                  ? NovaColors.darkOutline
                                  : NovaColors.lightOutline),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _dayLabels[index],
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? NovaColors.primary
                              : (isDark
                                  ? NovaColors.darkOnSurfaceVariant
                                  : NovaColors.lightOnSurfaceVariant),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark
                          ? NovaColors.darkOnSurfaceVariant
                          : NovaColors.lightOnSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      AlarmTimePickerResult(
                        hour: _selectedHour,
                        minute: _selectedMinute,
                        label: _labelController.text.trim().isEmpty
                            ? null
                            : _labelController.text.trim(),
                        repeatDays:
                            _selectedDays.isEmpty ? null : _selectedDays,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Result data from the alarm time picker dialog
class AlarmTimePickerResult {
  final int hour;
  final int minute;
  final String? label;
  final List<int>? repeatDays;

  const AlarmTimePickerResult({
    required this.hour,
    required this.minute,
    this.label,
    this.repeatDays,
  });
}
