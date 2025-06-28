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
            _buildReadingsList(context, cycle),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BillingCycle cycle) {
    final stats = [
      {
        'label': 'Current Reading',
        'value': cycle.formattedCurrentReading,
        'icon': Icons.speed,
        'color': Colors.blue,
      },
      {
        'label': 'Total Consumed',
        'value': cycle.formattedTotalConsumed,
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'label': 'Days Elapsed',
        'value': cycle.daysElapsed.toString(),
        'icon': Icons.calendar_today,
        'color': Colors.orange,
      },
      {
        'label': 'Status',
        'value': cycle.isActive ? 'Active' : 'Inactive',
        'icon': Icons.check_circle,
        'color': cycle.isActive ? Colors.green : Colors.grey,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(stats.length, (i) {
          return _buildStatCard(
            stats[i]['label'] as String,
            stats[i]['value'] as String,
            stats[i]['icon'] as IconData,
            stats[i]['color'] as Color,
          );
        }),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color.darken(0.2),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

  Widget _buildReadingsList(BuildContext context, BillingCycle cycle) {
    final readings = List<DailyReading>.from(cycle.dailyReadings);
    if (readings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Text('No readings yet.'),
        ),
      );
    }

    // Group readings by date string (yyyy-MM-dd)
    final Map<String, List<DailyReading>> readingsByDate = {};
    for (final r in readings) {
      final dateKey = r.readingDate.toIso8601String().split('T')[0];
      readingsByDate.putIfAbsent(dateKey, () => []).add(r);
    }

    // Sort date keys descending (latest first)
    final sortedDateKeys = readingsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('All Readings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...sortedDateKeys.map((dateKey) {
          final date = DateTime.parse(dateKey);
          final dateReadings = readingsByDate[dateKey]!;
          // Sort readings by time ascending, then reverse for display (latest first)
          dateReadings.sort((a, b) => a.readingTime.compareTo(b.readingTime));
          final readingsWithConsumption = <MapEntry<DailyReading, double>>[];
          double previousValue = cycle.startReading;
          for (final reading in dateReadings) {
            final consumed = reading.readingValue - previousValue;
            readingsWithConsumption.add(MapEntry(reading, consumed));
            previousValue = reading.readingValue;
          }
          final displayList = readingsWithConsumption.reversed.toList();
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(date),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                      ),
                      const Spacer(),
                      Text(
                        '${dateReadings.length} reading${dateReadings.length > 1 ? 's' : ''}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                ...displayList.map((entry) {
                  final reading = entry.key;
                  final consumed = entry.value;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(Icons.speed, color: Colors.blue, size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(
                          reading.formattedTime,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${reading.formattedReadingValue} units',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              consumed > 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 16,
                              color: consumed > 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              consumed > 0
                                  ? '+${consumed.toStringAsFixed(2)} consumed'
                                  : consumed < 0
                                      ? '${consumed.toStringAsFixed(2)} consumed'
                                      : 'No change',
                              style: TextStyle(
                                color: consumed > 0
                                    ? Colors.green
                                    : consumed < 0
                                        ? Colors.red
                                        : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (reading.notes != null &&
                            reading.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            reading.notes!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.dailyReadingShow,
                          arguments: reading,
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final readingDate = DateTime(date.year, date.month, date.day);

    if (readingDate == today) {
      return 'Today';
    } else if (readingDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
