import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manager_layout.dart';
import 'manager_payments_page.dart';
import 'manager_labours_page.dart';

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchDashboardData();
  }

  // ================= FETCH DASHBOARD DATA =================

  Future<_DashboardData> _fetchDashboardData() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Not authenticated');
    }

    final me = await client
        .from('users')
        .select('organisation_id, venue_id, organisations(name), venues(name)')
        .eq('id', user.id)
        .single();

    final orgId = me['organisation_id'];
    final venueId = me['venue_id'];

    int labourCount = 0;
    int supervisorCount = 0;

    if (venueId != null) {
      final labours = await client
          .from('users')
          .select('id')
          .eq('venue_id', venueId)
          .eq('role', 'LABOUR');

      final supervisors = await client
          .from('users')
          .select('id')
          .eq('venue_id', venueId)
          .eq('role', 'SUPERVISOR');

      labourCount = labours.length;
      supervisorCount = supervisors.length;
    }

    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();

    final txToday = await client
        .from('transactions')
        .select('amount')
        .eq('organisation_id', orgId)
        .gte('created_at', startOfDay);

    final todayPaid = txToday.fold<int>(
      0,
      (sum, t) => sum + (t['amount'] as int),
    );

    return _DashboardData(
      organisationName: me['organisations']['name'],
      venueName: me['venues']?['name'] ?? 'Site Not Assigned',
      labourCount: labourCount,
      supervisorCount: supervisorCount,
      todayPaid: todayPaid,
      todayTxCount: txToday.length,
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'Dashboard',
      child: FutureBuilder<_DashboardData>(
        future: _future,
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

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== STATS GRID =====
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 800
                      ? 4
                      : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                  children: [
                    _StatCard(
                      title: 'Total Labours',
                      value: data.labourCount.toString(),
                      icon: Icons.groups,
                      color: const Color(0xFF7B1FA2),
                      trend: 'Active workforce',
                    ),
                    _StatCard(
                      title: 'Supervisors',
                      value: data.supervisorCount.toString(),
                      icon: Icons.badge,
                      color: const Color(0xFF388E3C),
                      trend: 'Assigned',
                    ),
                    _StatCard(
                      title: 'Today Payments',
                      value: '₹ ${data.todayPaid}',
                      icon: Icons.payments,
                      color: const Color(0xFFE64A19),
                      trend: '${data.todayTxCount} transactions',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= QUICK ACTIONS =================

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickActionButton(
                icon: Icons.person_add,
                label: 'Team',
                color: const Color(0xFF7B1FA2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManagerTeamPage()),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.payments,
                label: 'Payment',
                color: const Color(0xFFE64A19),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManagerPaymentsPage(),
                    ),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.receipt_long,
                label: 'Transactions',
                color: const Color(0xFF388E3C),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManagerPaymentsPage(),
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

// ================= QUICK ACTION BUTTON =================

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
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
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 28, color: color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ================= STAT CARD =================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 28,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 4),
            Text(
              trend,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DATA MODEL =================

class _DashboardData {
  final String organisationName;
  final String venueName;
  final int labourCount;
  final int supervisorCount;
  final int todayPaid;
  final int todayTxCount;

  _DashboardData({
    required this.organisationName,
    required this.venueName,
    required this.labourCount,
    required this.supervisorCount,
    required this.todayPaid,
    required this.todayTxCount,
  });
}
