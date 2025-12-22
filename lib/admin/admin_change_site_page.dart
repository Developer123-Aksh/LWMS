import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_layout.dart';
import 'admin_home.dart';

class AdminChangeSitePage extends StatefulWidget {
  const AdminChangeSitePage({super.key});

  @override
  State<AdminChangeSitePage> createState() => _AdminChangeSitePageState();
}

class _AdminChangeSitePageState extends State<AdminChangeSitePage> {
  final client = Supabase.instance.client;

  String? _oldSiteId;
  String? _newSiteId;

  bool _loading = false;

  List<Map<String, dynamic>> _sites = [];

  int _managerCount = 0;
  int _supervisorCount = 0;
  int _labourCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  // ================= LOAD SITES =================

  Future<void> _loadSites() async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final me = await client
        .from('users')
        .select('organisation_id')
        .eq('id', user.id)
        .single();

    final res = await client
        .from('venues')
        .select('id, name, status')
        .eq('organisation_id', me['organisation_id'])
        .order('created_at');

    setState(() {
      _sites = List<Map<String, dynamic>>.from(res);
    });
  }

  // ================= LOAD COUNTS =================

  Future<void> _loadCounts(String siteId) async {
    final site = _sites.firstWhere((s) => s['id'] == siteId);

    if (site['status'] != 'ACTIVE') return;

    final users = await client
        .from('users')
        .select('role')
        .eq('venue_id', siteId)
        .eq('status', 'ACTIVE');

    setState(() {
      _managerCount =
          users.where((u) => u['role'] == 'MANAGER').length;
      _supervisorCount =
          users.where((u) => u['role'] == 'SUPERVISOR').length;
      _labourCount =
          users.where((u) => u['role'] == 'LABOUR').length;
    });
  }

  // ================= CHANGE SITE =================

  Future<void> _changeSite() async {
    if (_oldSiteId == null || _newSiteId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Site Change'),
        content: Text(
          'This will move:\n'
          '• $_managerCount Managers\n'
          '• $_supervisorCount Supervisors\n'
          '• $_labourCount Labours\n\n'
          'Old site will be marked COMPLETED.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    final user = client.auth.currentUser!;
    final me = await client
        .from('users')
        .select('organisation_id')
        .eq('id', user.id)
        .single();

    await client.rpc(
      'change_site_bulk',
      params: {
        'p_old_venue_id': _oldSiteId,
        'p_new_venue_id': _newSiteId,
        'p_org_id': me['organisation_id'],
      },
    );

    if (!mounted) return;

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team moved successfully')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      (_) => false,
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final completedCount =
        _sites.where((s) => s['status'] == 'COMPLETED').length;

    return AdminLayout(
      title: 'Change Site',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed Sites: $completedCount',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          const Text('Old Site',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _oldSiteId,
            items: _sites.map((s) {
              final isCompleted = s['status'] == 'COMPLETED';

              return DropdownMenuItem<String>(
                value: isCompleted ? null : s['id'],
                enabled: !isCompleted,
                child: Text(
                  isCompleted
                      ? '${s['name']} (COMPLETED)'
                      : s['name'],
                  style: TextStyle(
                    color:
                        isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _oldSiteId = val;
                _newSiteId = null;
              });
              _loadCounts(val);
            },
            decoration:
                const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 20),

          const Text('New Site',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _newSiteId,
            items: _sites
                .where((s) =>
                    s['status'] == 'ACTIVE' &&
                    s['id'] != _oldSiteId)
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s['id'],
                    child: Text(s['name']),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _newSiteId = val),
            decoration:
                const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 24),

          if (_oldSiteId != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('People to be moved',
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text('Managers: $_managerCount'),
                    Text('Supervisors: $_supervisorCount'),
                    Text('Labours: $_labourCount'),
                  ],
                ),
              ),
            ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _loading ||
                          _oldSiteId == null ||
                          _newSiteId == null
                      ? null
                      : _changeSite,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Move All & Complete Site'),
            ),
          ),
        ],
      ),
    );
  }
}
