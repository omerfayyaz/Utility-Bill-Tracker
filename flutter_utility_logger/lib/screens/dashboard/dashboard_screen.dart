import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../providers/daily_reading_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../billing_cycles/billing_cycles_screen.dart';
import '../daily_readings/daily_readings_screen.dart';
import '../profile/profile_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const DailyReadingsScreen(),
    const BillingCyclesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Readings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Cycles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utility Bill Logger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final billingCycleProvider = Provider.of<BillingCycleProvider>(
            context,
            listen: false,
          );
          final dailyReadingProvider = Provider.of<DailyReadingProvider>(
            context,
            listen: false,
          );
          await Future.wait([
            billingCycleProvider.fetchBillingCycles(),
            dailyReadingProvider.fetchDailyReadings(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                              ),
                              Text(
                                user?.name ?? 'User',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Active Cycle Section
              Consumer<BillingCycleProvider>(
                builder: (context, billingCycleProvider, child) {
                  final activeCycle = billingCycleProvider.activeCycle;

                  if (billingCycleProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (activeCycle == null) {
                    return _buildNoActiveCycleCard(context);
                  }

                  return _buildActiveCycleCard(context, activeCycle);
                },
              ),

              const SizedBox(height: 24),

              // Daily Reading Chart
              Consumer2<BillingCycleProvider, DailyReadingProvider>(
                builder: (context, billingCycleProvider, dailyReadingProvider,
                    child) {
                  final activeCycle = billingCycleProvider.activeCycle;
                  if (activeCycle == null) return const SizedBox.shrink();
                  final readings = dailyReadingProvider.dailyReadings
                      .where((r) => r.billingCycleId == activeCycle.id)
                      .toList()
                    ..sort((a, b) => a.readingDate.compareTo(b.readingDate));

                  if (dailyReadingProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (readings.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.show_chart,
                                color: AppTheme.primaryColor, size: 40),
                            const SizedBox(height: 12),
                            Text('No readings yet for this cycle.',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    );
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.show_chart,
                                  color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text('Daily Reading Trend',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                    show: true, drawVerticalLine: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true, reservedSize: 40),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx < 0 || idx >= readings.length)
                                          return const SizedBox.shrink();
                                        final date = readings[idx].readingDate;
                                        return Text('${date.month}/${date.day}',
                                            style:
                                                const TextStyle(fontSize: 10));
                                      },
                                      interval: (readings.length / 6)
                                          .ceilToDouble()
                                          .clamp(1, double.infinity),
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                        color: AppTheme.lightDivider)),
                                minX: 0,
                                maxX: (readings.length - 1).toDouble(),
                                minY: readings
                                    .map((r) => r.readingValue)
                                    .reduce((a, b) => a < b ? a : b),
                                maxY: readings
                                    .map((r) => r.readingValue)
                                    .reduce((a, b) => a > b ? a : b),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      for (int i = 0; i < readings.length; i++)
                                        FlSpot(i.toDouble(),
                                            readings[i].readingValue),
                                    ],
                                    isCurved: true,
                                    color: AppTheme.primaryColor,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context),

              const SizedBox(height: 24),

              // Recent Readings
              Text(
                'Recent Readings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildRecentReadings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoActiveCycleCard(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Billing Cycle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You need to create a billing cycle before adding readings.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.billingCycleCreate);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Billing Cycle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCycleCard(BuildContext context, dynamic activeCycle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Cycle',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Text(
                        activeCycle.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Current Reading',
                    activeCycle.formattedCurrentReading,
                    'units',
                    Icons.speed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Total Consumed',
                    activeCycle.formattedTotalConsumed,
                    'units',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Days Elapsed',
                    activeCycle.daysElapsed.toString(),
                    'days',
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Start Reading',
                    activeCycle.formattedStartReading,
                    'units',
                    Icons.start,
                  ),
                ),
              ],
            ),
          ],
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
        Icon(icon, size: 24, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Quick Add',
            'Add today\'s reading',
            Icons.add_circle_outline,
            AppTheme.primaryColor,
            () {
              Navigator.pushNamed(context, AppRoutes.dailyReadingQuickAdd);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Add Reading',
            'Add reading for any date',
            Icons.edit_calendar,
            AppTheme.secondaryColor,
            () {
              Navigator.pushNamed(context, AppRoutes.dailyReadingCreate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReadings(BuildContext context) {
    return Consumer<DailyReadingProvider>(
      builder: (context, dailyReadingProvider, child) {
        final recentReadings =
            dailyReadingProvider.sortedReadings.take(3).toList();

        if (recentReadings.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No readings yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by adding your first reading',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: recentReadings.map((reading) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.speed, color: AppTheme.primaryColor),
                ),
                title: Text(
                  '${reading.formattedReadingValue} units',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${reading.formattedDate} at ${reading.formattedTime}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.dailyReadingShow,
                    arguments: reading,
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
