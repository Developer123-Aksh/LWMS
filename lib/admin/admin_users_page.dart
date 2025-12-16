import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_layout.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
    Map<String, String> _venueIdNameMap = {};
  String _selectedRole = 'ALL';
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
    _initVenueIdNameMap();
  }

  Future<void> _initVenueIdNameMap() async {
    final venues = await _fetchVenues();
    setState(() {
      _venueIdNameMap = {
        for (var v in venues)
          if (v['id'] != null && v['name'] != null) v['id'].toString(): v['name'].toString(),
      };
    });
  }

  // ================= FETCH USERS =================

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('No current user found');
      return [];
    }

    final admin = await client
        .from('users')
        .select('organisation_id')
        .eq('id', currentUser.id)
        .single();
    debugPrint('Fetched admin: ${admin}');

    dynamic query = client
        .from('users')
        .select('id, name, mobile_no, role, status, venue_id')
        .eq('organisation_id', admin['organisation_id']);

    if (_selectedRole != 'ALL') {
      query = query.eq('role', _selectedRole);
    }

    final users = await query.order('created_at', ascending: false);
    debugPrint('Fetched users: ${users}');
    return users;
  }

  void _refresh() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  // ================= FETCH VENUES =================

  Future<List<Map<String, dynamic>>> _fetchVenues() async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('No current user found (venues)');
      return [];
    }

    final admin = await client
      .from('users')
      .select('organisation_id')
      .eq('id', currentUser.id)
      .single();
    debugPrint('Fetched admin for venues: ${admin}');

    final venues = await client
      .from('venues')
      .select('id, name')
      .eq('organisation_id', admin['organisation_id']);
    debugPrint('Fetched venues: ${venues}');
    return venues;
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Users',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final users = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add User'),
                  ),
                  DropdownButton<String>(
                    value: _selectedRole,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
                      DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
                      DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisor')),
                      DropdownMenuItem(value: 'LABOUR', child: Text('Labour')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedRole = v!);
                      _refresh();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (_, index) {
                          final u = users[index];
                          String siteName = 'Not Assigned';
                          if (u['venue_id'] != null && _venueIdNameMap.isNotEmpty) {
                            siteName = _venueIdNameMap[u['venue_id'].toString()] ?? 'Unknown';
                          }
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  (u['name'] ?? '?').toString().isNotEmpty
                                      ? u['name'][0]
                                      : '?',
                                ),
                              ),
                              title: Text(
                                u['name'] ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Role: ${u['role']}'),
                                  Text('Site: $siteName'),
                                  Text('Mobile: ${u['mobile_no'] ?? '-'}'),
                                  Text('Status: ${u['status']}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= ADD USER DIALOG =================

  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    String role = 'LABOUR';
    String? venueId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New User'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchVenues(),
          builder: (_, snapshot) {
            final venues = snapshot.data ?? [];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    value: venueId,
                    decoration: const InputDecoration(labelText: 'Site (Optional)'),
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
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final admin = await Supabase.instance.client
                  .from('users')
                  .select('organisation_id')
                  .eq(
                    'id',
                    Supabase.instance.client.auth.currentUser!.id,
                  )
                  .single();

              await _createUserByAdmin(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                mobile: mobileCtrl.text.trim(),
                password: passwordCtrl.text,
                role: role,
                organisationId: admin['organisation_id'],
                venueId: venueId,
              );

              _refresh();
            },
            child: const Text('Create User'),
          ),
        ],
      ),
    );
  }

  // ================= EDGE FUNCTION CALL =================

  Future<void> _createUserByAdmin({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required String role,
    required String organisationId,
    String? venueId,
  }) async {
    final client = Supabase.instance.client;

    debugPrint('Creating user with: name=$name, email=$email, mobile=$mobile, role=$role, organisationId=$organisationId, venueId=$venueId');

    final res = await client.functions.invoke(
      'create-user',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'mobile_no': mobile,
        'role': role,
        'organisation_id': organisationId,
        'venue_id': venueId,
      },
    );

    debugPrint('Create user response: status=${res.status}, data=${res.data}');

    if (res.status != 200) {
      debugPrint('Error creating user: ${res.data}');
      throw Exception(res.data);
    }
  }
}
