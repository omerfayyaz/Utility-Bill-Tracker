import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/daily_reading.dart';
import '../../providers/daily_reading_provider.dart';
import '../../utils/date_picker_widget.dart';

class DailyReadingEditScreen extends StatefulWidget {
  const DailyReadingEditScreen({Key? key}) : super(key: key);

  @override
  State<DailyReadingEditScreen> createState() => _DailyReadingEditScreenState();
}

class _DailyReadingEditScreenState extends State<DailyReadingEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _readingDate;
  late TimeOfDay _readingTime;
  late TextEditingController _readingValueController;
  late TextEditingController _notesController;
  bool _isSubmitting = false;
  String? _error;
  late DailyReading reading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is DailyReading) {
      reading = args;
      _readingDate = reading.readingDate;
      _readingTime = TimeOfDay(
          hour: reading.readingTime.hour, minute: reading.readingTime.minute);
      _readingValueController =
          TextEditingController(text: reading.readingValue.toString());
      _notesController = TextEditingController(text: reading.notes ?? '');
    }
  }

  @override
  void dispose() {
    _readingValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final provider = Provider.of<DailyReadingProvider>(context, listen: false);
    final success = await provider.updateDailyReading(
      id: reading.id,
      readingDate: _readingDate,
      readingTime: _readingTime,
      readingValue: double.tryParse(_readingValueController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    setState(() {
      _isSubmitting = false;
      _error = provider.error;
    });
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments is! DailyReading) {
      return const Scaffold(body: Center(child: Text('No reading provided.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Daily Reading'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DatePickerField(
                      label: 'Reading Date',
                      value: _readingDate,
                      onChanged: (date) => setState(() => _readingDate = date),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TimePickerField(
                      label: 'Reading Time',
                      value: _readingTime,
                      onChanged: (time) => setState(() => _readingTime = time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _readingValueController,
                decoration: const InputDecoration(
                  labelText: 'Reading Value (units)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 0) {
                    return 'Reading value must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
