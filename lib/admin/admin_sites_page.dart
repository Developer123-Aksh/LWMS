import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_layout.dart';

class AdminSitesPage extends StatefulWidget {
  const AdminSitesPage({super.key});

  @override
  State<AdminSitesPage> createState() => _AdminSitesPageState();
}

class _AdminSitesPageState extends State<AdminSitesPage> {
  String _searchQuery = '';
  late Future<List<Map<String, dynamic>>> _sitesFuture;

  @override
  void initState() {
    super.initState();
    _sitesFuture = _fetchSites();
  }

  // ================= FETCH SITES =================

  Future<List<Map<String, dynamic>>> _fetchSites() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final orgRes = await client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    final sites = await client
        .from('venues')
        .select('id, name, address, status')
        .eq('organisation_id', orgRes['organisation_id'])
        .order('created_at', ascending: false);

    for (final site in sites) {
      final users = await client
          .from('users')
          .select('role')
          .eq('venue_id', site['id'])
          .eq('status', 'ACTIVE');

      site['labour_count'] =
          users.where((u) => u['role'] == 'LABOUR').length;

      site['manager_name'] =
          users.any((u) => u['role'] == 'MANAGER')
              ? 'Assigned'
              : 'Not Assigned';
    }

    return List<Map<String, dynamic>>.from(sites);
  }

  void _refresh() {
    setState(() {
      _sitesFuture = _fetchSites();
    });
  }

  // ================= MARK COMPLETED =================

  Future<void> _markCompleted(String siteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Complete Site'),
        content:
            const Text('This site will be marked as COMPLETED.'),
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

    await Supabase.instance.client
        .from('venues')
        .update({'status': 'INACTIVE'})
        .eq('id', siteId);

    _refresh();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Sites',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sitesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allSites = snapshot.data!;
          final sites = allSites.where((s) {
            return s['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

          final activeCount =
              allSites.where((s) => s['status'] == 'ACTIVE').length;
          final completedCount =
              allSites.where((s) => s['status'] == 'INACTIVE').length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ACTION BAR
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddSiteDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Site'),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search sites...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // OVERVIEW
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      context,
                      title: 'Active Sites',
                      value: activeCount.toString(),
                      icon: Icons.construction,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildOverviewCard(
                      context,
                      title: 'Completed Sites',
                      value: completedCount.toString(),
                      icon: Icons.check_circle,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth > 800
                        ? _buildGridView(sites)
                        : _buildListView(sites);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= SITE CARDS =================

  Widget _buildGridView(List<Map<String, dynamic>> sites) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: sites.length,
      itemBuilder: (_, i) => _buildSiteCard(sites[i]),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> sites) {
    return ListView.builder(
      itemCount: sites.length,
      itemBuilder: (_, i) => _buildSiteCard(sites[i]),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    final isCompleted = site['status'] == 'INACTIVE';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    site['name'],
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'complete') {
                      _markCompleted(site['id']);
                    }
                  },
                  itemBuilder: (_) => [
                    if (!isCompleted)
                      const PopupMenuItem(
                        value: 'complete',
                        child: Text('Mark as Completed'),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(site['address'] ?? '-'),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    context,
                    icon: Icons.badge,
                    label: 'Manager',
                    value: site['manager_name'],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoChip(
                    context,
                    icon: Icons.groups,
                    label: 'Labours',
                    value: site['labour_count'].toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusChip(isCompleted ? 'Completed' : 'Active'),
          ],
        ),
      ),
    );
  }

  // ================= ADD SITE =================

  void _showAddSiteDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Site Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressCtrl,
              decoration:
                  const InputDecoration(labelText: 'Address'),
              maxLines: 2,
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
              await _addSite(
                nameCtrl.text.trim(),
                addressCtrl.text.trim(),
              );
              if (mounted) {
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text('Add Site'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSite(String name, String address) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final orgRes = await client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    await client.from('venues').insert({
      'organisation_id': orgRes['organisation_id'],
      'name': name,
      'address': address,
      'status': 'ACTIVE',
    });
  }

  // ================= SMALL UI =================

  Widget _buildOverviewCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(title),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isActive = status == 'Active';
    final color = isActive ? Colors.green : Colors.blue;

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.15),
    );
  }
}
