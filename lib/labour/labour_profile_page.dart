import 'package:flutter/material.dart';
import 'labour_layout.dart';

class LabourProfilePage extends StatelessWidget {
  const LabourProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LabourLayout(
      title: 'My Profile',
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ramesh Kumar',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Labour',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // This Month Summary
            _buildMonthlySummaryCard(context),
            const SizedBox(height: 16),
            
            // Work Information
            _buildSectionCard(
              context,
              title: 'Work Information',
              children: [
                _buildInfoRow(context, Icons.location_city, 'Assigned Site', 'Site A - Satellite, Ahmedabad'),
                _buildInfoRow(context, Icons.groups, 'Team', 'Team B'),
                _buildInfoRow(context, Icons.supervisor_account, 'Supervisor', 'Ramesh Patel'),
                _buildInfoRow(context, Icons.badge, 'Manager', 'Suresh Kumar'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Payment Details
            _buildSectionCard(
              context,
              title: 'Payment Details',
              children: [
                _buildInfoRow(context, Icons.currency_rupee, 'Daily Wage', '₹ 600/day'),
                _buildInfoRow(context, Icons.work, 'Work Type', 'Daily Wage'),
                _buildInfoRow(context, Icons.calendar_today, 'Joining Date', 'Jan 15, 2024'),
                _buildInfoRow(context, Icons.event, 'Total Days Worked', '265 days'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Personal Information
            _buildSectionCard(
              context,
              title: 'Personal Information',
              children: [
                _buildInfoRow(context, Icons.business, 'Organisation', 'ABC Constructions'),
                _buildInfoRow(context, Icons.phone, 'Mobile', '+91 9000000001'),
                _buildInfoRow(context, Icons.location_on, 'Address', 'Maninagar, Ahmedabad'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Settings Section
            _buildSectionCard(
              context,
              title: 'Settings',
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Notifications'),
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                ListTile(
                  leading: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Language'),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('English'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    label: 'Total Earned',
                    value: '₹18K',
                    color: Colors.blue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.check_circle,
                    label: 'Days Worked',
                    value: '22',
                    color: Colors.green,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.trending_up,
                    label: 'Attendance',
                    value: '95.6%',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}