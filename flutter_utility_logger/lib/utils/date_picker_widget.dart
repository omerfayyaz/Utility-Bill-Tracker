import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onChanged;
  final String? Function(DateTime?)? validator;
  final bool enabled;
  final String? hintText;
  final TextEditingController? controller;

  const DatePickerField({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.enabled = true,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.inputDecorationTheme.labelStyle?.color ??
        (isDark ? Colors.white : Colors.black87);
    final fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? AppTheme.darkSurface : Colors.white);
    final ctrl = controller ??
        TextEditingController(
            text:
                value != null ? DateFormat('MMM dd, yyyy').format(value!) : '');
    // Ensure label floats if value is present
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Select date',
        border: const OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today,
            color: enabled ? AppTheme.primaryColor : Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: textColor),
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      onTap: enabled ? () => _showDatePicker(context, ctrl) : null,
      validator: validator != null ? (s) => validator!(value) : null,
    );
  }

  Future<void> _showDatePicker(
      BuildContext context, TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onChanged(picked);
      ctrl.text = DateFormat('MMM dd, yyyy').format(picked);
    }
  }
}

class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final Function(TimeOfDay) onChanged;
  final String? Function(TimeOfDay?)? validator;
  final bool enabled;
  final String? hintText;
  final TextEditingController? controller;

  const TimePickerField({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.inputDecorationTheme.labelStyle?.color ??
        (isDark ? Colors.white : Colors.black87);
    final fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? AppTheme.darkSurface : Colors.white);
    final ctrl = controller ??
        TextEditingController(
            text: value != null ? value!.format(context) : '');
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Select time',
        border: const OutlineInputBorder(),
        suffixIcon: Icon(Icons.access_time,
            color: enabled ? AppTheme.primaryColor : Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: textColor),
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      onTap: enabled ? () => _showTimePicker(context, ctrl) : null,
      validator: validator != null ? (s) => validator!(value) : null,
    );
  }

  Future<void> _showTimePicker(
      BuildContext context, TextEditingController ctrl) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onChanged(picked);
      ctrl.text = picked.format(context);
    }
  }
}
