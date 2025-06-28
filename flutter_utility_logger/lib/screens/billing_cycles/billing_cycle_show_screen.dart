import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/billing_cycle.dart';
import '../../models/daily_reading.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../utils/constants.dart';

class BillingCycleShowScreen extends StatelessWidget {
  const BillingCycleShowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is! BillingCycle) {
      return const Scaffold(
          body: Center(child: Text('No billing cycle provided.')));
    }
    final cycle = args;
    return Scaffold(
      appBar: AppBar(
        title: Text(cycle.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Billing Cycle'),
                  content: const Text(
                      'Are you sure you want to delete this billing cycle? This action cannot be undone.'),
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
                    Provider.of<BillingCycleProvider>(context, listen: false);
                await provider.deleteBillingCycle(cycle.id);
                Navigator.of(context).pop();
              }
            },
          ),
          if (cycle.isActive)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.billingCycleEdit,
                    arguments: cycle);
              },
            ),
          if (cycle.isActive)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.dailyReadingCreate,
                    arguments: cycle);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(cycle),
            const SizedBox(height: 16),
            _buildCycleDetails(cycle),
            const SizedBox(height: 16),
            _buildReadingsList(cycle),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BillingCycle cycle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Current Reading', cycle.formattedCurrentReading,
            Icons.speed, Colors.blue),
        _buildStatCard('Total Consumed', cycle.formattedTotalConsumed,
            Icons.trending_up, Colors.green),
        _buildStatCard('Days Elapsed', cycle.daysElapsed.toString(),
            Icons.calendar_today, Colors.orange),
        _buildStatCard('Status', cycle.isActive ? 'Active' : 'Inactive',
            Icons.check_circle, cycle.isActive ? Colors.green : Colors.grey),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleDetails(BillingCycle cycle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cycle Information',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDetailRow('Start Date', cycle.formattedStartDate),
            _buildDetailRow(
                'Start Reading', '${cycle.formattedStartReading} units'),
            if (cycle.endDate != null)
              _buildDetailRow('End Date', cycle.formattedEndDate),
            if (cycle.endReading != null)
              _buildDetailRow(
                  'End Reading', '${cycle.formattedEndReading} units'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReadingsList(BillingCycle cycle) {
    final readings = cycle.dailyReadings;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Readings',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            readings.isEmpty
                ? const Text('No readings yet.')
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: readings.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final r = readings[i];
                      return ListTile(
                        title: Text('${r.readingValue} units'),
                        subtitle: Text(
                            '${r.readingDate.toLocal().toString().split(' ')[0]} ${_formatTime(r.readingTime)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.dailyReadingShow,
                                arguments: r);
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
