import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_reading_provider.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../models/daily_reading.dart';

class DailyReadingsScreen extends StatefulWidget {
  const DailyReadingsScreen({super.key});

  @override
  State<DailyReadingsScreen> createState() => _DailyReadingsScreenState();
}

class _DailyReadingsScreenState extends State<DailyReadingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Readings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.dailyReadingCreate);
            },
          ),
        ],
      ),
      body: Consumer2<DailyReadingProvider, BillingCycleProvider>(
        builder: (context, dailyReadingProvider, billingCycleProvider, child) {
          if (dailyReadingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeCycle = billingCycleProvider.activeCycle;
          if (activeCycle == null) {
            return _buildNoActiveCycleMessage(context);
          }

          final readingsByDate = dailyReadingProvider.readingsByDate;
          if (readingsByDate.isEmpty) {
            return _buildNoReadingsMessage(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await dailyReadingProvider.fetchDailyReadings();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: readingsByDate.length,
              itemBuilder: (context, index) {
                final sortedKeys = readingsByDate.keys.toList()
                  ..sort((a, b) => b.compareTo(a)); // Descending order
                final dateKey = sortedKeys[index];
                final readings = readingsByDate[dateKey]!;
                final date = DateTime.parse(dateKey);
                return _buildDateGroup(context, date, readings, activeCycle);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.dailyReadingQuickAdd);
        },
        icon: const Icon(Icons.add),
        label: const Text('Quick Add'),
      ),
    );
  }

  Widget _buildNoActiveCycleMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Active Billing Cycle',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a billing cycle to start adding readings',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.billingCycleCreate);
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Billing Cycle'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReadingsMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Readings Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your utility consumption',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.dailyReadingQuickAdd);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Reading'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(
    BuildContext context,
    DateTime date,
    List<DailyReading> readings,
    dynamic activeCycle,
  ) {
    // Sort readings by time (earliest first)
    readings.sort((a, b) => a.readingTime.compareTo(b.readingTime));

    // Calculate consumption for each reading
    final readingsWithConsumption = <MapEntry<DailyReading, double>>[];
    double previousValue = activeCycle.startReading;

    for (final reading in readings) {
      final consumed = reading.readingValue - previousValue;
      readingsWithConsumption.add(MapEntry(reading, consumed));
      previousValue = reading.readingValue;
    }

    // Reverse for display (latest first)
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
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                ),
                const Spacer(),
                Text(
                  '${readings.length} reading${readings.length > 1 ? 's' : ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Readings List
          ...displayList.map((entry) {
            final reading = entry.key;
            final consumed = entry.value;

            return _buildReadingTile(context, reading, consumed);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReadingTile(
    BuildContext context,
    DailyReading reading,
    double consumed,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(Icons.speed, color: AppTheme.primaryColor, size: 20),
      ),
      title: Row(
        children: [
          Text(
            reading.formattedTime,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${reading.formattedReadingValue} units',
              style: TextStyle(
                color: AppTheme.primaryColor,
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
                consumed > 0 ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color:
                    consumed > 0 ? AppTheme.successColor : AppTheme.errorColor,
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
                      ? AppTheme.successColor
                      : consumed < 0
                          ? AppTheme.errorColor
                          : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (reading.notes != null && reading.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              reading.notes!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'view':
              Navigator.pushNamed(
                context,
                AppRoutes.dailyReadingShow,
                arguments: reading,
              );
              break;
            case 'edit':
              Navigator.pushNamed(
                context,
                AppRoutes.dailyReadingEdit,
                arguments: reading,
              );
              break;
            case 'delete':
              _showDeleteDialog(context, reading);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20),
                SizedBox(width: 8),
                Text('View'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.dailyReadingShow,
          arguments: reading,
        );
      },
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

  void _showDeleteDialog(BuildContext context, DailyReading reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: Text(
          'Are you sure you want to delete the reading of ${reading.formattedReadingValue} units from ${reading.formattedDate} at ${reading.formattedTime}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<DailyReadingProvider>(
                context,
                listen: false,
              );
              await provider.deleteDailyReading(reading.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
