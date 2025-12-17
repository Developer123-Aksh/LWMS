import 'package:flutter/material.dart';
import 'supervisor_layout.dart';
import '../services/profile_service.dart'; 

class SupervisorDashboardPage extends StatefulWidget {
  const SupervisorDashboardPage({super.key});

  @override
  State<SupervisorDashboardPage> createState() =>
      _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState extends State<SupervisorDashboardPage> {
  late Future<_DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_DashboardStats> _loadStats() async {
    final team = await SupervisorService.fetchTeam();
    final txns = await SupervisorService.fetchTransactions();

    final today = DateTime.now();

    int totalLabours =
        team.where((u) => u['role'] == 'LABOUR').length;

    double todaySalary = 0;
    double todayAdvances = 0;

    for (final t in txns) {
      final createdAt = DateTime.parse(t['created_at']);

      if (createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day) {
        final amount = (t['amount'] as num).toDouble();

        if (t['payment_type'] == 'DAILY_WAGE') {
          todaySalary += amount;
        } else if (t['payment_type'] == 'ADVANCE') {
          todayAdvances += amount;
        }
      }
    }

    return _DashboardStats(
      totalLabours: totalLabours,
      todaySalary: todaySalary,
      todayAdvances: todayAdvances,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SupervisorLayout(
      title: 'Dashboard',
      child: FutureBuilder<_DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 24),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 800 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    _StatCard(
                      title: 'Total Labours',
                      value: stats.totalLabours.toString(),
                      icon: Icons.groups,
                      color: const Color(0xFF388E3C),
                    ),
                    _StatCard(
                      title: 'Today Salary',
                      value: '₹ ${stats.todaySalary.toStringAsFixed(0)}',
                      icon: Icons.payment_rounded,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Today Advances',
                      value: '₹ ${stats.todayAdvances.toStringAsFixed(0)}',
                      icon: Icons.payments,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, Supervisor',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Overview of today\'s site activity',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.supervisor_account,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStats {
  final int totalLabours;
  final double todaySalary;
  final double todayAdvances;

  _DashboardStats({
    required this.totalLabours,
    required this.todaySalary,
    required this.todayAdvances,
  });
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
