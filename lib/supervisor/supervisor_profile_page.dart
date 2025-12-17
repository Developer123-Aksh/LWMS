import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supervisor_layout.dart';
import '../services/profile_service.dart';

class SupervisorProfilePage extends StatefulWidget {
  const SupervisorProfilePage({super.key});

  @override
  State<SupervisorProfilePage> createState() =>
      _SupervisorProfilePageState();
}

class _SupervisorProfilePageState extends State<SupervisorProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SupervisorService.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return SupervisorLayout(
      title: 'My Profile',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
            final aadhar = data['aadhar_no'] ?? '-';

          final venueText = data['venue_name'] == null
              ? '-'
              : data['venue_address'] != null
                  ? '${data['venue_name']}, ${data['venue_address']}'
                  : data['venue_name'];

          return SingleChildScrollView(
            child: Column(
              children: [
                _header(context, data),
                const SizedBox(height: 24),

                _section(context, 'Personal Information', [
                  _row(Icons.business, 'Organisation', data['org_name'] ?? '-'),
                  _row(Icons.email, 'Email', data['email_id']),
                  _row(Icons.phone, 'Mobile', data['mobile_no'] ?? '-'),
                  _row(Icons.credit_card, 'Aadhaar Number', aadhar),
                ]),

                const SizedBox(height: 16),

                _section(context, 'Work Details', [
                  _row(Icons.location_city, 'Assigned Site', venueText),
                  _row(Icons.check_circle, 'Status', data['status']),
                  _row(
                    Icons.calendar_today,
                    'Member Since',
                    _formatDate(DateTime.parse(data['created_at'])),
                  ),
                ]),

                const SizedBox(height: 16),

                _section(context, 'Settings', [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(BuildContext context, Map<String, dynamic> data) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(
              data['name'],
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Chip(label: Text(data['role'])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(context, data),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EDIT =================

  void _showEditProfileDialog(
      BuildContext context, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    final mobileCtrl =
        TextEditingController(text: data['mobile_no'] ?? '');
    final aadharCtrl =
        TextEditingController(text: data['aadhar_no'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile')),
            TextField(controller: aadharCtrl, decoration: const InputDecoration(labelText: 'Aadhaar')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await SupervisorService.updateProfile(
                name: nameCtrl.text,
                mobile: mobileCtrl.text,
                aadhar: aadharCtrl.text,
              );
              setState(() {
                _profileFuture = SupervisorService.fetchProfile();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ================= PASSWORD =================

  void _showChangePasswordDialog(BuildContext context) {
    final p1 = TextEditingController();
    final p2 = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: p1, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            TextField(controller: p2, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (p1.text != p2.text) return;
              await Supabase.instance.client.auth
                  .updateUser(UserAttributes(password: p1.text));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
