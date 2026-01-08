import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_layout.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedRole = 'ALL';
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final admin = await client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    var q = client
        .from('users')
        .select('id,name,mobile_no,role,status,venue_id')
        .eq('organisation_id', admin['organisation_id']);

    if (_selectedRole != 'ALL') {
      q = q.eq('role', _selectedRole);
    }

    return await q.order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> _fetchVenues() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final admin = await client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    return await client
        .from('venues')
        .select('id,name')
        .eq('organisation_id', admin['organisation_id'])
        .order('name');
  }

  void _refresh() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Users',
      child: Column(
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All')),
                  DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
                  DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisor')),
                  DropdownMenuItem(value: 'LABOUR', child: Text('Labour')),
                ],
                onChanged: (v) {
                  _selectedRole = v!;
                  _refresh();
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (_, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (s.hasError) {
                  return Center(child: Text(s.error.toString()));
                }

                final users = s.data!;
                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    final role = u['role'];

                    return Card(
                      child: ListTile(
                        title: Text(u['name']),
                        subtitle: Text(
                          '$role • ${u['mobile_no']}'
                          '${u['venue_id'] == null ? ' • Site not assigned' : ''}',
                        ),
                        trailing: role == 'ADMIN'
                            ? null
                            : PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') {
                                    _showEditUserDialog(u);
                                  } else if (v == 'reset') {
                                    _showResetDialog(
                                      userId: u['id'],
                                      userName: u['name'],
                                    );
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit User'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'reset',
                                    child: Row(
                                      children: [
                                        Icon(Icons.lock_reset, size: 18),
                                        SizedBox(width: 8),
                                        Text('Reset Password'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= ADD USER (SITE REQUIRED) =================

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();

    String role = 'LABOUR';
    String? venueId;
    String? venueError;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Add User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile')),
                TextField(
                  controller: salaryCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Salary'),
                ),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
                    DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisor')),
                    DropdownMenuItem(value: 'LABOUR', child: Text('Labour')),
                  ],
                  onChanged: (v) => role = v!,
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchVenues(),
                  builder: (_, s) {
                    if (!s.hasData) return const SizedBox();
                    return DropdownButtonFormField<String>(
                      value: venueId,
                      decoration: InputDecoration(
                        labelText: 'Assign Site *',
                        errorText: venueError,
                      ),
                      items: s.data!
                          .map<DropdownMenuItem<String>>(
                            (v) => DropdownMenuItem<String>(
                              value: v['id'] as String,
                              child: Text(v['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setLocal(() {
                          venueId = v;
                          venueError = null;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                if (venueId == null) {
                  setLocal(() {
                    venueError = 'Site is required';
                  });
                  return;
                }

                Navigator.pop(context);

                final salary = int.tryParse(salaryCtrl.text.trim()) ?? 0;

                final admin = await Supabase.instance.client
                    .from('users')
                    .select('organisation_id')
                    .eq('id', Supabase.instance.client.auth.currentUser!.id)
                    .single();

                await Supabase.instance.client.functions.invoke(
                  'create-user',
                  body: {
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'password': passwordCtrl.text,
                    'mobile_no': mobileCtrl.text.trim(),
                    'role': role,
                    'organisation_id': admin['organisation_id'],
                    'venue_id': venueId,
                    'salary': salary,
                    'remaining_salary': salary,
                  },
                );

                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= EDIT USER =================

  void _showEditUserDialog(Map<String, dynamic> user) async {
    String role = user['role'];
    String? venueId = user['venue_id'];
    final venues = await _fetchVenues();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
                DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisor')),
                DropdownMenuItem(value: 'LABOUR', child: Text('Labour')),
              ],
              onChanged: (v) => role = v!,
            ),
            DropdownButtonFormField<String?>(
              value: venueId,
              decoration: const InputDecoration(labelText: 'Assign Site'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Not Assigned')),
                ...venues.map(
                  (v) => DropdownMenuItem(
                    value: v['id'],
                    child: Text(v['name']),
                  ),
                ),
              ],
              onChanged: (v) => venueId = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              Navigator.pop(context);

              await Supabase.instance.client
                  .from('users')
                  .update({
                    'role': role,
                    'venue_id': venueId,
                  })
                  .eq('id', user['id']);

              _refresh();
            },
          ),
        ],
      ),
    );
  }

  // ================= RESET PASSWORD =================

  void _showResetDialog({
    required String userId,
    required String userName,
  }) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: $userName'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Reset'),
            onPressed: () async {
              Navigator.pop(context);

              await Supabase.instance.client.functions.invoke(
                'reset-user-password',
                body: {
                  'user_id': userId,
                  'password': ctrl.text.trim(),
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
