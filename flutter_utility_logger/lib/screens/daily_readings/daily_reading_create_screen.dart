import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/billing_cycle.dart';
import '../../providers/daily_reading_provider.dart';
import '../../utils/date_picker_widget.dart';

class DailyReadingCreateScreen extends StatefulWidget {
  const DailyReadingCreateScreen({Key? key}) : super(key: key);

  @override
  State<DailyReadingCreateScreen> createState() =>
      _DailyReadingCreateScreenState();
}

class _DailyReadingCreateScreenState extends State<DailyReadingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _readingDate;
  TimeOfDay _readingTime = TimeOfDay.now();
  final _readingValueController = TextEditingController();
  final _notesController = TextEditingController();
  int? _billingCycleId;
  bool _isSubmitting = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is BillingCycle) {
      _billingCycleId = args.id;
      _readingValueController.text = args.currentReading.toString();
    }
  }

  @override
  void dispose() {
    _readingValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _readingDate == null) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final provider = Provider.of<DailyReadingProvider>(context, listen: false);
    final success = await provider.createDailyReading(
      billingCycleId: _billingCycleId!,
      readingDate: _readingDate!,
      readingTime: _readingTime,
      readingValue: double.tryParse(_readingValueController.text.trim()) ?? 0,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Daily Reading'),
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
                      validator: (date) =>
                          date == null ? 'Reading date is required' : null,
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
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
