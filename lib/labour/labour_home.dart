import 'package:flutter/material.dart';
import 'labour_layout.dart';
import '../services/profile_service.dart';

class LabourDashboardPage extends StatelessWidget {
  const LabourDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LabourLayout(
      title: 'Dashboard',
      currentIndex: 0,
      child: FutureBuilder<Map<String, dynamic>>(
        future: LabourService.fetchDashboard(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final d = snap.data!;
          // print('Dashboard Data: $d');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context, d),
                const SizedBox(height: 24),

                _InfoCard(
                  title: 'Monthly Salary',
                  value: '₹ ${d['salary']}',
                  subtitle: 'This month',
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF1976D2),
                ),
                const SizedBox(height: 12),

                _InfoCard(
                  title: 'Advance Taken',
                  value: '₹ ${d['due_advance']}',
                  subtitle: 'This month',
                  icon: Icons.payments,
                  color: const Color(0xFFE64A19),
                ),
                const SizedBox(height: 12),

                _InfoCard(
                  title: 'Balance Due',
                  value: '₹ ${d['remaining_salary']}',
                  subtitle: 'To be received',
                  icon: Icons.savings,
                  color: const Color(0xFF388E3C),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= WELCOME CARD =================

  Widget _buildWelcomeCard(BuildContext context, Map<String, dynamic> d) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting!',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d['name'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _info(Icons.location_city, d['venue_name'], context),
                _info(Icons.supervisor_account, d['supervisor_name'], context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

// ================= INFO CARD =================

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
