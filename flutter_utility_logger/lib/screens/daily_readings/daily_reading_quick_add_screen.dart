import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/billing_cycle.dart';
import '../../providers/daily_reading_provider.dart';
import '../../providers/billing_cycle_provider.dart';

class DailyReadingQuickAddScreen extends StatefulWidget {
  const DailyReadingQuickAddScreen({Key? key}) : super(key: key);

  @override
  State<DailyReadingQuickAddScreen> createState() =>
      _DailyReadingQuickAddScreenState();
}

class _DailyReadingQuickAddScreenState
    extends State<DailyReadingQuickAddScreen> {
  final _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate()) return;
    if (_billingCycleId == null) {
      setState(() {
        _error = 'No billing cycle selected. Please go back and try again.';
      });
      return;
    }
    final readingValue = double.tryParse(_readingValueController.text.trim());
    if (readingValue == null || readingValue < 0) {
      setState(() {
        _error = 'Reading value must be a positive number.';
      });
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final provider = Provider.of<DailyReadingProvider>(context, listen: false);
    final success = await provider.quickAddDailyReading(
      billingCycleId: _billingCycleId!,
      readingValue: readingValue,
      readingTime: _readingTime,
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
              content: Text(provider.error ?? 'Reading added successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } else if (_error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _readingTime,
    );
    if (picked != null) setState(() => _readingTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quick Add Today's Reading"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Reading Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_readingTime.format(context)),
                ),
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
                onPressed:
                    _isSubmitting || _billingCycleId == null ? null : _submit,
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
