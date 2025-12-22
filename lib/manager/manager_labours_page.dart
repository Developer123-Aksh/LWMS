import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';
import 'manager_layout.dart';

class ManagerTeamPage extends StatefulWidget {
  const ManagerTeamPage({super.key});

  @override
  State<ManagerTeamPage> createState() => _ManagerTeamPageState();
}

class _ManagerTeamPageState extends State<ManagerTeamPage> {
  String _roleFilter = 'ALL';
  String _statusFilter = 'ALL';

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ManagerService.fetchTeamMembers(
      role: _roleFilter,
      status: _statusFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'My Team',
      child: Column(
        children: [
          _filters(),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (_, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (s.hasError) {
                  return Center(child: Text(s.error.toString()));
                }

                final data = s.data!;
                if (data.isEmpty) {
                  return const Center(child: Text('No team members found'));
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, i) {
                    final u = data[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(u['name'][0]),
                        ),
                        title: Text(u['name']),
                        subtitle: Text('${u['role']} • ${u['mobile_no']}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'reset') {
                              _resetPassword(u);
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

  Widget _filters() {
    return Row(
      children: [
        DropdownButton<String>(
          value: _roleFilter,
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
            DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisors')),
            DropdownMenuItem(value: 'LABOUR', child: Text('Labours')),
          ],
          onChanged: (v) {
            setState(() {
              _roleFilter = v!;
              _reload();
            });
          },
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: _statusFilter,
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('All Status')),
            DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
            DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
          ],
          onChanged: (v) {
            setState(() {
              _statusFilter = v!;
              _reload();
            });
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Add'),
        ),
      ],
    );
  }

  // ======================================================
  // ADD TEAM MEMBER
  // ======================================================
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final salaryCtrl = TextEditingController(); // ✅ NEW
    String role = 'LABOUR';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add'),
        content: SingleChildScrollView(
          child: Column(
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
                controller: salaryCtrl, // ✅ NEW
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Salary'),
              ),
              TextField(
                controller: passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'LABOUR', child: Text('Labour')),
                  DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisor')),
                ],
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: 'Role'),
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

              await ManagerService.createUserByManager(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                mobile: mobileCtrl.text.trim(),
                password: passwordCtrl.text,
                role: role,
                salary: int.tryParse(salaryCtrl.text) ?? 0, // ✅ NEW
              );

              setState(_reload);
            },
          ),
        ],
      ),
    );
  }

  // ======================================================
  // RESET PASSWORD
  // ======================================================
  Future<void> _resetPassword(Map<String, dynamic> user) async {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Reset'),
            onPressed: () async {
              Navigator.pop(context);

              final res = await Supabase.instance.client.functions.invoke(
                'reset-user-password',
                body: {
                  'user_id': user['id'],
                  'new_password': ctrl.text.trim(),
                },
              );

              if (res.status != 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed: ${res.data}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset successfully')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
