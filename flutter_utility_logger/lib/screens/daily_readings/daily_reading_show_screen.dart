import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/daily_reading.dart';
import '../../models/billing_cycle.dart';
import '../../providers/daily_reading_provider.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../utils/constants.dart';

class DailyReadingShowScreen extends StatefulWidget {
  const DailyReadingShowScreen({Key? key}) : super(key: key);

  @override
  State<DailyReadingShowScreen> createState() => _DailyReadingShowScreenState();
}

class _DailyReadingShowScreenState extends State<DailyReadingShowScreen> {
  DailyReading? reading;
  BillingCycle? cycle;
  double? consumedSincePrevious;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is DailyReading) {
      _loadReading(args);
    }
  }

  Future<void> _loadReading(DailyReading r) async {
    final dailyReadingProvider =
        Provider.of<DailyReadingProvider>(context, listen: false);
    final billingCycleProvider =
        Provider.of<BillingCycleProvider>(context, listen: false);
    final allReadings =
        dailyReadingProvider.getReadingsForCycle(r.billingCycleId);
    allReadings.sort((a, b) {
      final dateCmp = a.readingDate.compareTo(b.readingDate);
      if (dateCmp != 0) return dateCmp;
      return a.readingTime.compareTo(b.readingTime);
    });
    final idx = allReadings.indexWhere((x) => x.id == r.id);
    double? consumed;
    if (idx > 0) {
      consumed = r.readingValue - allReadings[idx - 1].readingValue;
    } else if (idx == 0 && billingCycleProvider.billingCycles.isNotEmpty) {
      final cycle = billingCycleProvider.billingCycles.firstWhere(
          (c) => c.id == r.billingCycleId,
          orElse: () => billingCycleProvider.activeCycle!);
      consumed = r.readingValue - cycle.startReading;
    }
    setState(() {
      reading = r;
      cycle = billingCycleProvider.billingCycles.firstWhere(
          (c) => c.id == r.billingCycleId,
          orElse: () => billingCycleProvider.activeCycle!);
      consumedSincePrevious = consumed;
    });
  }

  Future<void> _editReading() async {
    if (reading == null) return;
    final result = await Navigator.pushNamed(
        context, AppRoutes.dailyReadingEdit,
        arguments: reading);
    if (result == true) {
      // Re-fetch readings and billing cycles, then update
      final dailyReadingProvider =
          Provider.of<DailyReadingProvider>(context, listen: false);
      final billingCycleProvider =
          Provider.of<BillingCycleProvider>(context, listen: false);
      await Future.wait([
        dailyReadingProvider.fetchDailyReadings(),
        billingCycleProvider.fetchBillingCycles(),
      ]);
      final updated = dailyReadingProvider.dailyReadings
          .firstWhere((r) => r.id == reading!.id, orElse: () => reading!);
      _loadReading(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reading == null || cycle == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Edit Reading'),
                    onPressed: _editReading,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    label: const Text('Delete Reading'),
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
                        final provider = Provider.of<DailyReadingProvider>(
                            context,
                            listen: false);
                        await provider.deleteDailyReading(reading!.id);
                        Navigator.of(context).pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('View reading information and consumption data',
                style: TextStyle(color: Colors.grey[700], fontSize: 15)),
            const SizedBox(height: 18),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${reading!.formattedFullDate}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reading!.formattedTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            reading!.formattedReadingValue,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                                color: Colors.blue),
                          ),
                          const SizedBox(height: 4),
                          const Text('Reading Value (units)',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          if (consumedSincePrevious != null)
                            Column(
                              children: [
                                Text(
                                  (consumedSincePrevious! >= 0 ? '+' : '') +
                                      consumedSincePrevious!.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: consumedSincePrevious! > 0
                                        ? Colors.green
                                        : consumedSincePrevious! < 0
                                            ? Colors.red
                                            : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Consumed Since Previous',
                                  style: TextStyle(
                                    color: consumedSincePrevious! > 0
                                        ? Colors.green
                                        : consumedSincePrevious! < 0
                                            ? Colors.red
                                            : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Billing Cycle: ${cycle!.name}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                            'Start: ${cycle!.formattedStartDate} (${cycle!.formattedStartReading} units)',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up,
                            size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                            'Total Consumed: ${cycle!.formattedTotalConsumed} units',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
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
