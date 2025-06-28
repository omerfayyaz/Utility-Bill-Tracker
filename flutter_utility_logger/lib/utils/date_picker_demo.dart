import 'package:flutter/material.dart';
import 'date_picker_widget.dart';

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});

  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Picker Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Modern Calendar-Style Date Pickers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Date Picker Demo
            DatePickerField(
              label: 'Select Date',
              value: _selectedDate,
              onChanged: (date) => setState(() => _selectedDate = date),
              hintText: 'Tap to open calendar picker',
            ),

            const SizedBox(height: 24),

            // Time Picker Demo
            TimePickerField(
              label: 'Select Time',
              value: _selectedTime,
              onChanged: (time) => setState(() => _selectedTime = time),
              hintText: 'Tap to open time picker',
            ),

            const SizedBox(height: 32),

            // Display selected values
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Values:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                        'Date: ${_selectedDate?.toString() ?? 'Not selected'}'),
                    Text(
                        'Time: ${_selectedTime?.format(context) ?? 'Not selected'}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Features list
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('• Modern calendar-style interface'),
                    Text('• Consistent with app theme'),
                    Text('• Proper validation support'),
                    Text('• Accessible and user-friendly'),
                    Text('• Customizable date ranges'),
                    Text('• Beautiful animations'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
