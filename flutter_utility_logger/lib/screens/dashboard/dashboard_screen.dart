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
import '../../models/billing_cycle.dart';

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

  int _mapNavIndexToScreenIndex(int navIndex) {
    // navIndex: 0=Home, 1=Readings, 2=FAB, 3=Cycles, 4=Profile
    if (navIndex < 2) return navIndex;
    if (navIndex == 2) return _currentIndex; // ignore FAB tap, stay on current
    return navIndex - 1; // 3->2, 4->3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_mapNavIndexToScreenIndex(_currentIndex)],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.dailyReadingCreate);
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) return; // Ignore FAB center tap
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
            icon: SizedBox.shrink(), // Center space for FAB
            label: '',
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

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Fetch daily units for the bar chart
    Future.microtask(() =>
        Provider.of<DailyReadingProvider>(context, listen: false)
            .fetchDailyUnits());
  }

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
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 4, top: 8, right: 4, bottom: 8),
                    child: Row(
                      children: [
                        Text('Welcome, ',
                            style: Theme.of(context).textTheme.bodyLarge),
                        Text(
                          user?.name ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Billing Cycles Listing Card (for comparison)
              Consumer<BillingCycleProvider>(
                builder: (context, billingCycleProvider, child) {
                  final activeCycle = billingCycleProvider.activeCycle;
                  if (activeCycle == null) return const SizedBox.shrink();
                  return _buildCycleCard(context, activeCycle);
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

              // Daily Units Bar Chart
              Consumer<DailyReadingProvider>(
                builder: (context, dailyReadingProvider, child) {
                  if (dailyReadingProvider.isUnitsLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (dailyReadingProvider.unitsError != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Card(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: AppTheme.errorColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dailyReadingProvider.unitsError!,
                                  style: TextStyle(color: AppTheme.errorColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  final units = dailyReadingProvider.dailyUnits;
                  if (units.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.bar_chart,
                                  color: AppTheme.primaryColor, size: 40),
                              const SizedBox(height: 12),
                              Text('No daily units data yet.',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bar_chart,
                                  color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text('Daily Units Consumption',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How many units you used each day in this cycle',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.white,
                                    tooltipRoundedRadius: 12,
                                    tooltipPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      final idx = group.x.toInt();
                                      final date = units[idx].date;
                                      return BarTooltipItem(
                                        '${date.substring(5)}\n',
                                        const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                '${rod.toY.toStringAsFixed(2)} units',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: AppTheme.lightDivider,
                                    strokeWidth: 1,
                                  ),
                                ),
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
                                        if (idx < 0 || idx >= units.length)
                                          return const SizedBox.shrink();
                                        final date = units[idx].date;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            date.substring(5),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        );
                                      },
                                      interval: (units.length / 6)
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
                                  border:
                                      Border.all(color: AppTheme.lightDivider),
                                ),
                                minY: 0,
                                maxY: units
                                        .map((u) => u.unitsConsumed)
                                        .fold<double>(0,
                                            (prev, e) => e > prev ? e : prev) +
                                    1,
                                barGroups: [
                                  for (int i = 0; i < units.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: units[i].unitsConsumed,
                                          color: AppTheme.primaryColor,
                                          width: 18,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                          backDrawRodData:
                                              BackgroundBarChartRodData(
                                            show: true,
                                            toY: 0,
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.08),
                                          ),
                                        ),
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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.dailyReadingCreate);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Reading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),

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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Active Cycle',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              activeCycle.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Started ${activeCycle.formattedStartDate} with ${activeCycle.formattedStartReading} units',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              activeCycle.formattedCurrentReading,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Current Reading',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      activeCycle.formattedTotalConsumed,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Consumed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      activeCycle.daysElapsed.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Days Passed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
          children: recentReadings.asMap().entries.map((entry) {
            final i = entry.key;
            final reading = entry.value;
            // Calculate consumed value
            double previousValue;
            if (i == recentReadings.length - 1) {
              // Last in the list, use startReading from active cycle if available
              final billingCycleProvider =
                  Provider.of<BillingCycleProvider>(context, listen: false);
              final activeCycle = billingCycleProvider.activeCycle;
              previousValue = activeCycle?.startReading ?? 0;
            } else {
              previousValue = recentReadings[i + 1].readingValue;
            }
            final consumed = reading.readingValue - previousValue;
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${reading.formattedDate} at ${reading.formattedTime}',
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          consumed > 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 16,
                          color: consumed > 0
                              ? AppTheme.successColor
                              : consumed < 0
                                  ? AppTheme.errorColor
                                  : Colors.grey[600],
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
                  ],
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

  Widget _buildCycleCard(BuildContext context, BillingCycle cycle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // No navigation on dashboard
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
                      ? (cycle.daysElapsedValue / 30).clamp(0.0, 1.0)
                      : 0.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${cycle.daysElapsedValue} days elapsed',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
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
}
