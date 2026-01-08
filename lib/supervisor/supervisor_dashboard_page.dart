import 'package:flutter/material.dart';
import 'supervisor_layout.dart';
import '../services/profile_service.dart';
import 'supervisor_labours_page.dart';
import 'supervisor_transactions_page.dart';

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

    final totalLabours =
        team.where((u) => u['role'] == 'LABOUR').length;

    double todaySalary = 0;
    double todayAdvances = 0;

    for (final t in txns) {
      final createdAt = DateTime.parse(t['created_at']);

      if (createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day) {
        final amount = (t['amount'] as num).toDouble();

        if (t['payment_type'] == 'SALARY') {
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                // ===== STATS =====
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
                      icon: Icons.payments,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Today Advances',
                      value: '₹ ${stats.todayAdvances.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ===== QUICK LINKS (CIRCULAR ROW) =====
                _buildQuickLinks(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== WELCOME CARD =====
  

  // ===== QUICK LINKS =====
  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickLinkButton(
                icon: Icons.groups,
                label: 'Team',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupervisorLaboursPage(),
                    ),
                  );
                },
              ),
              _QuickLinkButton(
                icon: Icons.receipt_long,
                label: 'Transactions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupervisorTransactionsPage(),
                    ),
                  );
                },
              ),
              _QuickLinkButton(
                icon: Icons.payments,
                label: 'Payments',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupervisorTransactionsPage(),
                    ),
                  );
                },
              ),
              _QuickLinkButton(
                icon: Icons.location_city,
                label: 'Site',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Site overview coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== DATA MODEL =====
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

// ===== STAT CARD =====
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
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
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
                Text(title),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===== QUICK LINK BUTTON (CIRCULAR) =====
class _QuickLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(40),
            child: CircleAvatar(
              radius: 36,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.15),
              child: Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
