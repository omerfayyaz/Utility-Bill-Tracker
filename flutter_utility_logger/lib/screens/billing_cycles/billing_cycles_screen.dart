import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../models/billing_cycle.dart';

class BillingCyclesScreen extends StatefulWidget {
  const BillingCyclesScreen({super.key});

  @override
  State<BillingCyclesScreen> createState() => _BillingCyclesScreenState();
}

class _BillingCyclesScreenState extends State<BillingCyclesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Cycles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.billingCycleCreate);
            },
          ),
        ],
      ),
      body: Consumer<BillingCycleProvider>(
        builder: (context, billingCycleProvider, child) {
          if (billingCycleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final billingCycles = billingCycleProvider.billingCycles;
          if (billingCycles.isEmpty) {
            return _buildNoCyclesMessage(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await billingCycleProvider.fetchBillingCycles();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: billingCycles.length,
              itemBuilder: (context, index) {
                final cycle = billingCycles[index];
                return _buildCycleCard(context, cycle);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.billingCycleCreate);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Cycle'),
      ),
    );
  }

  Widget _buildNoCyclesMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Billing Cycles',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first billing cycle to start tracking',
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
            label: const Text('Create First Cycle'),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCard(BuildContext context, BillingCycle cycle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.billingCycleShow,
            arguments: cycle,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cycle.isActive
                          ? AppTheme.successColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: cycle.isActive
                          ? AppTheme.successColor
                          : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cycle.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (cycle.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Active',
                                  style: TextStyle(
                                    color: AppTheme.successColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cycle.formattedStartDate} - ${cycle.formattedEndDate}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          Navigator.pushNamed(
                            context,
                            AppRoutes.billingCycleShow,
                            arguments: cycle,
                          );
                          break;
                        case 'edit':
                          Navigator.pushNamed(
                            context,
                            AppRoutes.billingCycleEdit,
                            arguments: cycle,
                          );
                          break;
                        case 'delete':
                          _showDeleteDialog(context, cycle);
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
                ],
              ),

              const SizedBox(height: 16),

              // Statistics Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Start Reading',
                      cycle.formattedStartReading,
                      'units',
                      Icons.start,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Current Reading',
                      cycle.formattedCurrentReading,
                      'units',
                      Icons.speed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Total Consumed',
                      cycle.formattedTotalConsumed,
                      'units',
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              if (cycle.isActive) ...[
                LinearProgressIndicator(
                  value: cycle.daysElapsedValue > 0
                      ? (cycle.daysElapsedValue / 30).clamp(
                          0.0,
                          1.0,
                        ) // Assuming 30-day cycles
                      : 0.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${cycle.daysElapsedValue} days elapsed',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, BillingCycle cycle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Billing Cycle'),
        content: Text(
          'Are you sure you want to delete the billing cycle "${cycle.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<BillingCycleProvider>(
                context,
                listen: false,
              );
              await provider.deleteBillingCycle(cycle.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
