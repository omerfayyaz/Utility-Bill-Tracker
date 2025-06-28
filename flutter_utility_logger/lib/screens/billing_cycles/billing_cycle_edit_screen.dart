import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/billing_cycle.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../utils/date_picker_widget.dart';

class BillingCycleEditScreen extends StatefulWidget {
  const BillingCycleEditScreen({Key? key}) : super(key: key);

  @override
  State<BillingCycleEditScreen> createState() => _BillingCycleEditScreenState();
}

class _BillingCycleEditScreenState extends State<BillingCycleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _startDate;
  late TextEditingController _startReadingController;
  DateTime? _endDate;
  late TextEditingController _endReadingController;
  bool _isSubmitting = false;
  String? _error;
  late BillingCycle cycle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is BillingCycle) {
      cycle = args;
      _nameController = TextEditingController(text: cycle.name);
      _startDate = cycle.startDate;
      _startReadingController =
          TextEditingController(text: cycle.startReading.toString());
      _endDate = cycle.endDate;
      _endReadingController =
          TextEditingController(text: cycle.endReading?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startReadingController.dispose();
    _endReadingController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final provider = Provider.of<BillingCycleProvider>(context, listen: false);
    final success = await provider.updateBillingCycle(
      id: cycle.id,
      name: _nameController.text.trim(),
      startDate: _startDate,
      startReading: double.tryParse(_startReadingController.text.trim()),
      endDate: _endDate,
      endReading: _endReadingController.text.trim().isNotEmpty
          ? double.tryParse(_endReadingController.text.trim())
          : null,
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
                Text(provider.error ?? 'Billing cycle updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else if (_error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments is! BillingCycle) {
      return const Scaffold(
          body: Center(child: Text('No billing cycle provided.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Billing Cycle'),
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
                onChanged: (date) => setState(() => _startDate = date),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startReadingController,
                decoration: const InputDecoration(
                  labelText: 'Start Reading (units)',
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
              const SizedBox(height: 16),
              DatePickerField(
                label: 'End Date (optional)',
                value: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
                firstDate: _startDate,
                lastDate: DateTime.now(),
                hintText: 'Leave empty if cycle is still active',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endReadingController,
                decoration: const InputDecoration(
                  labelText: 'End Reading (units, optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final val = double.tryParse(value);
                  if (val == null || val < 0) {
                    return 'End reading must be a positive number';
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
                    : const Text('Update'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildStatsBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Statistics',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildStatRow(
              'Total Consumed:', '${cycle.formattedTotalConsumed} units'),
          _buildStatRow('Days Elapsed:', '${cycle.daysElapsed} days'),
          _buildStatRow('Status:', cycle.isActive ? 'Active' : 'Inactive',
              valueColor: cycle.isActive ? Colors.green : Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }
}
