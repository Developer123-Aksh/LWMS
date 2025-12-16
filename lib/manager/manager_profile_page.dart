import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manager_layout.dart';

class ManagerProfilePage extends StatefulWidget {
  const ManagerProfilePage({super.key});

  @override
  State<ManagerProfilePage> createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  // ================= FETCH PROFILE =================

  Future<Map<String, dynamic>> _fetchProfile() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    // 1️⃣ Fetch manager row
    final user = await client
        .from('users')
        .select('''
          name,
          email_id,
          mobile_no,
          aadhar_no,
          role,
          status,
          created_at,
          organisation_id,
          venue_id
        ''')
        .eq('id', uid)
        .single();

    // 2️⃣ Fetch organisation name
    String orgName = '-';
    if (user['organisation_id'] != null) {
      final org = await client
          .from('organisation')
          .select('name')
          .eq('id', user['organisation_id'])
          .maybeSingle();

      if (org != null) {
        orgName = org['name'] ?? '-';
      }
    }

    // 3️⃣ Fetch venue (site)
    String venueName = 'Not Assigned';
    String venueAddress = '';
    if (user['venue_id'] != null) {
      final venue = await client
          .from('venues')
          .select('name, address')
          .eq('id', user['venue_id'])
          .maybeSingle();

      if (venue != null) {
        venueName = venue['name'] ?? 'Not Assigned';
        venueAddress = venue['address'] ?? '';
      }
    }

    return {
      ...Map<String, dynamic>.from(user),
      'org_name': orgName,
      'venue_name': venueName,
      'venue_address': venueAddress,
    };
  }

  // ================= UPDATE PROFILE =================

  Future<void> _updateProfile({
    required String name,
    required String mobile,
    required String aadhar,
  }) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    await client.from('users').update({
      'name': name,
      'mobile_no': mobile,
      'aadhar_no': aadhar.isEmpty ? null : aadhar,
    }).eq('id', uid);

    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'My Profile',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          final String aadhar =
              (data['aadhar_no'] == null || data['aadhar_no'].toString().trim().isEmpty)
                  ? '-'
                  : data['aadhar_no'].toString();

          return SingleChildScrollView(
            child: Column(
              children: [
                // ================= HEADER =================
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
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
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['name'] ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['role'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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

                // ================= PERSONAL INFO =================
                _section(context, 'Personal Information', [
                  _row(Icons.business, 'Organisation', data['org_name']),
                  _row(Icons.email, 'Email', data['email_id']),
                  _row(Icons.phone, 'Mobile', data['mobile_no'] ?? '-'),
                  _row(Icons.credit_card, 'Aadhaar Number', aadhar),
                ]),

                const SizedBox(height: 16),

                // ================= WORK DETAILS (SITE HERE) =================
                _section(context, 'Work Details', [
                  _row(
                    Icons.location_city,
                    'Assigned Site',
                    data['venue_address'].toString().isNotEmpty
                        ? '${data['venue_name']}, ${data['venue_address']}'
                        : data['venue_name'],
                  ),
                  _row(Icons.check_circle, 'Status', data['status']),
                  _row(
                    Icons.calendar_today,
                    'Member Since',
                    _formatDate(DateTime.parse(data['created_at'])),
                  ),
                ]),

                const SizedBox(height: 16),

                // ================= SETTINGS =================
                _section(context, 'Settings', [
                  ListTile(
                    leading: Icon(Icons.security,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Change Password'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
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

  // ================= EDIT DIALOG =================

  void _showEditProfileDialog(
      BuildContext context, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final mobileCtrl = TextEditingController(text: data['mobile_no'] ?? '');
    final aadharCtrl =
        TextEditingController(text: data['aadhar_no']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 16),
            TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile')),
            const SizedBox(height: 16),
            TextField(controller: aadharCtrl, decoration: const InputDecoration(labelText: 'Aadhaar Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _updateProfile(
                name: nameCtrl.text.trim(),
                mobile: mobileCtrl.text.trim(),
                aadhar: aadharCtrl.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

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
            const SizedBox(height: 16),
            TextField(controller: p2, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (p1.text != p2.text) return;
              await Supabase.instance.client.auth.updateUser(
                UserAttributes(password: p1.text),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
