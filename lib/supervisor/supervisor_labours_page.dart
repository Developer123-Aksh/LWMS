import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'supervisor_layout.dart';

class SupervisorLaboursPage extends StatefulWidget {
  const SupervisorLaboursPage({super.key});

  @override
  State<SupervisorLaboursPage> createState() =>
      _SupervisorLaboursPageState();
}

class _SupervisorLaboursPageState extends State<SupervisorLaboursPage> {
  String _search = '';
  String _roleFilter = 'ALL';
  String _statusFilter = 'ALL';

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = SupervisorService.fetchTeam();
  }

  @override
  Widget build(BuildContext context) {
    return SupervisorLayout(
      title: 'Team',
      child: Column(
        children: [
          _filters(context),
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

                var data = s.data ?? [];

                // ---------- APPLY FILTERS ----------
                data = data.where((u) {
                  final name = (u['name'] ?? '').toString().toLowerCase();
                  final mobile = (u['mobile_no'] ?? '').toString();
                  final role = u['role'];
                  final status = u['status'];

                  if (_roleFilter != 'ALL' && role != _roleFilter) {
                    return false;
                  }
                  if (_statusFilter != 'ALL' && status != _statusFilter) {
                    return false;
                  }
                  if (_search.isNotEmpty &&
                      !name.contains(_search.toLowerCase()) &&
                      !mobile.contains(_search)) {
                    return false;
                  }
                  return true;
                }).toList();

                if (data.isEmpty) {
                  return const Center(child: Text('No team members found'));
                }

                return ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final u = data[i];
                    return _teamTile(context, u);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER BAR =================

  Widget _filters(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search name or mobile',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        DropdownButton<String>(
          value: _roleFilter,
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
            DropdownMenuItem(value: 'LABOUR', child: Text('Labours')),
            DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisors')),
          ],
          onChanged: (v) => setState(() => _roleFilter = v!),
        ),
        DropdownButton<String>(
          value: _statusFilter,
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('All Status')),
            DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
            DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
          ],
          onChanged: (v) => setState(() => _statusFilter = v!),
        ),
      ],
    );
  }

  // ================= TILE =================

  Widget _teamTile(BuildContext context, Map<String, dynamic> u) {
    final roleColor =
        u['role'] == 'SUPERVISOR' ? Colors.blue : Colors.deepPurple;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: roleColor.withOpacity(0.15),
        child: Text(
          u['name'][0],
          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        u['name'],
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${u['role']} • ${u['mobile_no']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(u['status']),
            backgroundColor: u['status'] == 'ACTIVE'
                ? Colors.green.withOpacity(0.15)
                : Colors.grey.withOpacity(0.2),
          ),
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
            ],
            onSelected: (_) => _showDetails(context, u),
          ),
        ],
      ),
    );
  }

  // ================= DETAILS =================

  void _showDetails(BuildContext context, Map<String, dynamic> u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(u['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Role', u['role']),
            _row('Mobile', u['mobile_no']),
            _row('Status', u['status']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }
}
