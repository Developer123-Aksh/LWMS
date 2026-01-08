import 'package:flutter/material.dart';
import 'admin_layout.dart';
import '../services/profile_service.dart';
import 'admin_payment_page.dart';
import 'admin_transection_page.dart';
import 'admin_users_page.dart';
import 'admin_change_site_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Dashboard',
      child: FutureBuilder<Map<String, dynamic>>(
        future: AdminDashboardService.fetchDashboard(),
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

                // ===== STATS =====
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 800 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _StatCard(
                      title: 'Total Sites',
                      value: data['total_sites'].toString(),
                      icon: Icons.location_city,
                      color: const Color(0xFF1976D2),
                    ),
                    _StatCard(
                      title: 'Managers',
                      value: data['total_managers'].toString(),
                      icon: Icons.badge,
                      color: const Color(0xFF7B1FA2),
                    ),
                    _StatCard(
                      title: 'Labours',
                      value: data['total_labours'].toString(),
                      icon: Icons.groups,
                      color: const Color(0xFFE64A19),
                    ),
                    _StatCard(
                      title: 'Payout This Month',
                      value: '₹ ${data['monthly_payout']}',
                      icon: Icons.payments,
                      color: const Color(0xFF388E3C),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ===== QUICK ACTIONS (CIRCULAR ROW) =====
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
    );
  }


  // ===== QUICK ACTIONS =====
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickActionButton(
                icon: Icons.person_add,
                label: 'Add User',
                color: const Color(0xFF1976D2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUsersPage(),
                    ),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.payments,
                label: 'Payment',
                color: const Color(0xFF388E3C),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPaymentsPage(),
                    ),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.receipt_long,
                label: 'Transactions',
                color: const Color(0xFFE64A19),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminTransactionsPage(),
                    ),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.swap_horiz,
                label: 'Move Site',
                color: const Color(0xFF7B1FA2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminChangeSitePage(),
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

// ===== QUICK ACTION BUTTON =====
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
