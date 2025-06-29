import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/billing_cycle.dart';
import '../../providers/daily_reading_provider.dart';
import '../../utils/date_picker_widget.dart';
import '../../providers/billing_cycle_provider.dart';

class DailyReadingCreateScreen extends StatefulWidget {
  const DailyReadingCreateScreen({Key? key}) : super(key: key);

  @override
  State<DailyReadingCreateScreen> createState() =>
      _DailyReadingCreateScreenState();
}

class _DailyReadingCreateScreenState extends State<DailyReadingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _readingDate = DateTime.now();
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
    } else {
      // Try to get active cycle from provider
      final billingCycleProvider =
          Provider.of<BillingCycleProvider>(context, listen: false);
      final activeCycle = billingCycleProvider.activeCycle;
      if (activeCycle != null) {
        _billingCycleId = activeCycle.id;
        _readingValueController.text = activeCycle.currentReading.toString();
      } else {
        setState(() {
          _error = 'No active billing cycle found. Please create one first.';
        });
      }
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
    if (_billingCycleId == null) {
      setState(() {
        _error = 'No billing cycle selected. Please go back and try again.';
      });
      return;
    }
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
      // Refresh dashboard data
      final billingCycleProvider =
          Provider.of<BillingCycleProvider>(context, listen: false);
      final dailyReadingProvider =
          Provider.of<DailyReadingProvider>(context, listen: false);
      await Future.wait([
        billingCycleProvider.fetchBillingCycles(),
        dailyReadingProvider.fetchDailyReadings(),
      ]);
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Reading added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 20,
              bottom: 16,
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else if (_error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            bottom: 16,
          ),
        ),
      );
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
