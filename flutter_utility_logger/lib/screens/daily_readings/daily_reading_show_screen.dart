import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/daily_reading.dart';
import '../../providers/daily_reading_provider.dart';
import '../../utils/constants.dart';

class DailyReadingShowScreen extends StatelessWidget {
  const DailyReadingShowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is! DailyReading) {
      return const Scaffold(body: Center(child: Text('No reading provided.')));
    }
    final reading = args;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.dailyReadingEdit,
                  arguments: reading);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Reading'),
                  content: const Text(
                      'Are you sure you want to delete this reading? This action cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true) {
                final provider =
                    Provider.of<DailyReadingProvider>(context, listen: false);
                await provider.deleteDailyReading(reading.id);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reading.formattedFullDate,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(reading.formattedTime,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(reading.formattedReadingValue,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Colors.blue)),
                              const SizedBox(height: 4),
                              const Text('Reading Value (units)',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (reading.notes != null && reading.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('Notes',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(reading.notes!,
                          style: const TextStyle(color: Colors.black87)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Billing Cycle Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    Text('Cycle ID: ${reading.billingCycleId}'),
                    // You can fetch and show more cycle info if needed
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
