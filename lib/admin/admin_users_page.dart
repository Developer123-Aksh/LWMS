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
        .select('id,name,mobile_no,role,status')
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
                        subtitle: Text('$role • ${u['mobile_no']}'),
                        trailing: role == 'ADMIN'
                            ? null
                            : PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'reset') {
                                    _showResetDialog(
                                      userId: u['id'],
                                      userName: u['name'],
                                    );
                                  }
                                },
                                itemBuilder: (_) => const [
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

  // ================= ADD USER =================

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final salaryCtrl = TextEditingController(); // ✅ USED NOW

    String role = 'LABOUR';
    String? venueId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: mobileCtrl,
                decoration: const InputDecoration(labelText: 'Mobile'),
              ),
              TextField(
                controller: salaryCtrl, // ✅ SALARY INPUT
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
                  return DropdownButtonFormField<String?>(
                    value: venueId,
                    decoration: const InputDecoration(labelText: 'Assign Site'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Not Assigned'),
                      ),
                      ...s.data!.map(
                            (v) => DropdownMenuItem(
                          value: v['id'],
                          child: Text(v['name']),
                        ),
                      ),
                    ],
                    onChanged: (v) => venueId = v,
                  );
                },
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
            child: const Text('Create'),
            onPressed: () async {
              Navigator.pop(context);

              final salary = int.tryParse(salaryCtrl.text.trim()) ?? 0;

              final admin = await Supabase.instance.client
                  .from('users')
                  .select('organisation_id')
                  .eq(
                'id',
                Supabase.instance.client.auth.currentUser!.id,
              )
                  .single();

              final res = await Supabase.instance.client.functions.invoke(
                'create-user',
                body: {
                  'name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'password': passwordCtrl.text,
                  'mobile_no': mobileCtrl.text.trim(),
                  'role': role,
                  'organisation_id': admin['organisation_id'],
                  'venue_id': venueId,
                  'salary': salary,              // ✅ FIXED
                  'remaining_salary': salary,    // ✅ FIXED
                },
              );

              if (res.status != 200) {
                throw Exception(res.data);
              }

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

              final res = await Supabase.instance.client.functions.invoke(
                'reset-user-password',
                body: {
                  'user_id': userId,
                  'password': ctrl.text.trim(),
                },
              );

              if (res.status != 200) {
                throw Exception(res.data);
              }
            },
          ),
        ],
      ),
    );
  }
}
