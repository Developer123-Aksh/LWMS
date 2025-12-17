import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'labour_layout.dart';
import '../services/profile_service.dart';
import '../auth/login_page.dart'; // 🔴 CHANGE if your login widget name differs

class LabourProfilePage extends StatefulWidget {
  const LabourProfilePage({super.key});

  @override
  State<LabourProfilePage> createState() => _LabourProfilePageState();
}

class _LabourProfilePageState extends State<LabourProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = LabourService.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return LabourLayout(
      title: 'My Profile',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          final name = data['name'] ?? '-';
          final role = data['role'] ?? '-';
          final status = data['status'] ?? '-';
          final mobile = data['mobile_no'] ?? '-';
          final aadhar = data['aadhar_no'] ?? '-';
          final orgName = data['org_name'] ?? '-';
          final venueName = data['venue_name'] ?? 'Not Assigned';
          final venueAddress = data['venue_address'] ?? '';
          final joinedDate = data['created_at'] != null
              ? _formatDate(DateTime.parse(data['created_at']))
              : '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= HEADER =================
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        _pill(
                          role,
                          Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        _pill(
                          status,
                          status == 'ACTIVE' ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showEditProfileDialog(context, data),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================= WORK INFO =================
                _section('Work Information', [
                  _row(Icons.business, 'Organisation', orgName),
                  _row(
                    Icons.location_city,
                    'Assigned Site',
                    venueAddress.isNotEmpty
                        ? '$venueName, $venueAddress'
                        : venueName,
                  ),
                  _row(Icons.calendar_today, 'Joined Date', joinedDate),
                ]),

                const SizedBox(height: 16),

                // ================= PERSONAL INFO =================
                _section('Personal Information', [
                  _row(Icons.phone, 'Mobile', mobile),
                  _row(Icons.credit_card, 'Aadhaar Number', aadhar),
                ]),

                const SizedBox(height: 16),

                // ================= SETTINGS =================
                _section('Settings', [
                  ListTile(
                    leading: Icon(Icons.security,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Change Password'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _confirmLogout(context),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= EDIT PROFILE =================

  void _showEditProfileDialog(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final mobileCtrl =
        TextEditingController(text: data['mobile_no'] ?? '');
    final aadharCtrl =
        TextEditingController(text: data['aadhar_no']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mobileCtrl,
                decoration: const InputDecoration(labelText: 'Mobile'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aadharCtrl,
                decoration: const InputDecoration(labelText: 'Aadhaar Number'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              await LabourService.updateProfile(
                name: nameCtrl.text.trim(),
                mobile: mobileCtrl.text.trim(),
                aadhar: aadharCtrl.text.trim(),
              );

              if (mounted) {
                setState(() {
                  _profileFuture = LabourService.fetchProfile();
                });
                Navigator.pop(context);
              }
            },
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
            TextField(
              controller: p1,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: p2,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirm Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () async {
              if (p1.text != p2.text) return;

              await Supabase.instance.client.auth.updateUser(
                UserAttributes(password: p1.text),
              );

              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ================= LOGOUT =================

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginUIPage(),
                ),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
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
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
