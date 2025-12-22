import 'package:flutter/material.dart';
import 'admin_layout.dart';
import '../services/profile_service.dart';
import 'admin_payment_page.dart';
import 'admin_transection_page.dart';
import 'admin_users_page.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== WELCOME =====
                _buildWelcomeCard(context, data['admin_name']),
                const SizedBox(height: 24),

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

                // ===== QUICK ACTIONS AT BOTTOM =====
                _buildQuickActions(context),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== WELCOME CARD =====
  Widget _buildWelcomeCard(BuildContext context, String adminName) {
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
                    'Welcome back, $adminName!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s what\'s happening with your projects today.',
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
              Icons.waving_hand,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
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

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              icon: Icons.person_add,
              label: 'Add User',
              color: const Color(0xFF1976D2),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminUsersPage()));
              },
            ),
            _QuickActionButton(
              icon: Icons.payments,
              label: 'Make Payment',
              color: const Color(0xFF388E3C),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminPaymentsPage()));
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
                        builder: (_) => const AdminTransactionsPage()));
              },
            ),
            _QuickActionButton(
              icon: Icons.groups,
              label: 'View Users',
              color: const Color(0xFF7B1FA2),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminUsersPage()));
              },
            ),
          ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
