import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_layout.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final res = await client
        .from('users')
        .select('''
          name,
          email_id,
          mobile_no,
          aadhar_no,
          role,
          status,
          created_at,
          organisations(name)
        ''')
        .eq('id', uid)
        .single();

    return res;
  }

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
      'aadhar_no': aadhar,
    }).eq('id', uid);

    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'My Profile',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
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
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color:
                                Theme.of(context).colorScheme.primary,
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
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['role'],
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showEditProfileDialog(context, data),
                          icon: const Icon(Icons.edit),
                          label:
                              const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Personal Information
                _buildSectionCard(
                  context,
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.business,
                      'Organisation',
                      data['organisations']['name'],
                    ),
                    _buildInfoRow(
                      context,
                      Icons.email,
                      'Email',
                      data['email_id'],
                    ),
                    _buildInfoRow(
                      context,
                      Icons.phone,
                      'Mobile',
                      data['mobile_no'] ?? '-',
                    ),
                    _buildInfoRow(
                      context,
                      Icons.credit_card,
                      'Aadhaar Number',
                      data['aadhar_no'] ?? '-',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Organisation Details (UID REMOVED)
                _buildSectionCard(
                  context,
                  title: 'Organisation Details',
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.check_circle,
                      'Status',
                      data['status'],
                    ),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Member Since',
                      _formatDate(
                        DateTime.parse(data['created_at']),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Settings Section (unchanged)
                _buildSectionCard(
                  context,
                  title: 'Settings',
                  children: [
                    ListTile(
                      leading: Icon(Icons.notifications,
                          color: Theme.of(context)
                              .colorScheme
                              .primary),
                      title:
                          const Text('Notifications'),
                      trailing:
                          Switch(value: true, onChanged: (_) {}),
                    ),
                    ListTile(
  leading: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
  title: const Text('Change Password'),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () => _showChangePasswordDialog(context),
),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= DIALOG =================

  void _showEditProfileDialog(
      BuildContext context, Map<String, dynamic> data) {
    final nameCtrl =
        TextEditingController(text: data['name']);
    final mobileCtrl =
        TextEditingController(text: data['mobile_no']);
    final aadharCtrl =
        TextEditingController(text: data['aadhar_no']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mobileCtrl,
              decoration:
                  const InputDecoration(labelText: 'Mobile'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aadharCtrl,
              decoration: const InputDecoration(
                  labelText: 'Aadhaar Number'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color:
                  Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showChangePasswordDialog(BuildContext context) {
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  bool loading = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: loading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: loading
                ? null
                : () async {
                    if (newPasswordCtrl.text !=
                        confirmPasswordCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                        ),
                      );
                      return;
                    }

                    if (newPasswordCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Password must be at least 6 characters'),
                        ),
                      );
                      return;
                    }

                    setState(() => loading = true);

                    try {
                      await Supabase.instance.client.auth.updateUser(
                        UserAttributes(
                          password: newPasswordCtrl.text,
                        ),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Password updated successfully'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    } finally {
                      setState(() => loading = false);
                    }
                  },
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update Password'),
          ),
        ],
      ),
    ),
  );
}

}
