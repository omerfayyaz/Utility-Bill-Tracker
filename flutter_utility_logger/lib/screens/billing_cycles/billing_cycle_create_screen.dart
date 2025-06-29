import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../utils/date_picker_widget.dart';
import '../../utils/theme.dart';

class BillingCycleCreateScreen extends StatefulWidget {
  const BillingCycleCreateScreen({Key? key}) : super(key: key);

  @override
  State<BillingCycleCreateScreen> createState() =>
      _BillingCycleCreateScreenState();
}

class _BillingCycleCreateScreenState extends State<BillingCycleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _startDate;
  final _startReadingController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _startReadingController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _startDate == null) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final provider = Provider.of<BillingCycleProvider>(context, listen: false);
    final success = await provider.createBillingCycle(
      name: _nameController.text.trim(),
      startDate: _startDate!,
      startReading: double.tryParse(_startReadingController.text.trim()) ?? 0,
    );
    setState(() {
      _isSubmitting = false;
      _error = provider.error;
    });
    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(provider.error ?? 'Billing cycle created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 20,
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
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Billing Cycle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Cycle Name',
                  hintText: 'e.g., January 2024, Q1 2024',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Cycle name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Start Date',
                value: _startDate,
                validator: (date) =>
                    date == null ? 'Start date is required' : null,
                onChanged: (date) => setState(() => _startDate = date),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                hintText: 'Select the start date for this billing cycle',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startReadingController,
                decoration: const InputDecoration(
                  labelText: 'Start Reading (units)',
                  hintText: 'Enter starting meter reading',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 0) {
                    return 'Start reading must be a positive number';
                  }
                  return null;
                },
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
                    : const Text('Create Cycle'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkSurface
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkDivider
                        : Colors.blue.shade100,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About Billing Cycles',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.primaryColor
                              : Colors.blue,
                        )),
                    const SizedBox(height: 8),
                    Text('• Only one cycle can be active at a time',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkText
                              : Colors.black87,
                        )),
                    Text(
                        '• Creating a new cycle will deactivate the current one',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkText
                              : Colors.black87,
                        )),
                    Text('• You can add daily readings to track consumption',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkText
                              : Colors.black87,
                        )),
                    Text(
                        '• End date and reading can be set later when the cycle ends',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkText
                              : Colors.black87,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
