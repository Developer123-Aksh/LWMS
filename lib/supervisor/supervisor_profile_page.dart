import 'package:flutter/material.dart';
import 'supervisor_layout.dart';

class SupervisorProfilePage extends StatelessWidget {
  const SupervisorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SupervisorLayout(
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
                        'Supervisor',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Performance Summary
            _buildPerformanceCard(context),
            const SizedBox(height: 16),
            
            // Personal Information
            _buildSectionCard(
              context,
              title: 'Personal Information',
              children: [
                _buildInfoRow(context, Icons.business, 'Organisation', 'ABC Constructions'),
                _buildInfoRow(context, Icons.location_city, 'Assigned Site', 'Site A - Satellite, Ahmedabad'),
                _buildInfoRow(context, Icons.groups, 'Team', 'Team B'),
                _buildInfoRow(context, Icons.phone, 'Mobile', '+91 9988776655'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Work Details
            _buildSectionCard(
              context,
              title: 'Team Details',
              children: [
                _buildInfoRow(context, Icons.groups, 'Total Labours', '28'),
                _buildInfoRow(context, Icons.badge, 'Reporting To', 'Suresh Patel (Manager)'),
                _buildInfoRow(context, Icons.calendar_today, 'Joining Date', 'Mar 10, 2023'),
                _buildInfoRow(context, Icons.check_circle, 'Status', 'Active'),
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

  Widget _buildPerformanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    context,
                    icon: Icons.payments,
                    label: 'Total Paid',
                    value: '₹1.28L',
                    color: Colors.green,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Transactions',
                    value: '142',
                    color: Colors.blue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    context,
                    icon: Icons.check_circle,
                    label: 'Attendance',
                    value: '86%',
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

  Widget _buildPerformanceItem(
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