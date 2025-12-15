import 'package:flutter/material.dart';
import 'admin_layout.dart';
// import '../theme_provider.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedRole = 'All';
  
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Users',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action bar
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedRole,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Roles')),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'Supervisor', child: Text('Supervisor')),
                    DropdownMenuItem(value: 'Labour', child: Text('Labour')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // User cards
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Desktop layout - Table view
                  return _buildTableView();
                } else {
                  // Mobile layout - Card view
                  return _buildCardView();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.surfaceVariant,
          ),
          columns: const [
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Site', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(
            8,
            (index) => DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _getRoleColor(_getUserRole(index)).withOpacity(0.2),
                        child: Text(
                          _getUserName(index)[0],
                          style: TextStyle(
                            color: _getRoleColor(_getUserRole(index)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_getUserName(index)),
                    ],
                  ),
                ),
                DataCell(_buildRoleBadge(_getUserRole(index))),
                DataCell(Text(_getUserSite(index))),
                DataCell(Text(_getUserMobile(index))),
                DataCell(_buildStatusBadge(_getUserStatus(index))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {},
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () {},
                        tooltip: 'View Details',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        final role = _getUserRole(index);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor(role).withOpacity(0.2),
              child: Text(
                _getUserName(index)[0],
                style: TextStyle(
                  color: _getRoleColor(role),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              _getUserName(index),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildRoleBadge(role),
                const SizedBox(height: 4),
                Text('Site: ${_getUserSite(index)}'),
                Text('Mobile: ${_getUserMobile(index)}'),
                const SizedBox(height: 4),
                _buildStatusBadge(_getUserStatus(index)),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 12),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    final color = _getRoleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'Active' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Manager':
        return const Color(0xFF7B1FA2);
      case 'Supervisor':
        return const Color(0xFF388E3C);
      case 'Labour':
        return const Color(0xFFE64A19);
      default:
        return const Color(0xFF1976D2);
    }
  }

  String _getUserName(int index) {
    final names = [
      'Suresh Patel',
      'Ram Kumar',
      'Vijay Singh',
      'Prakash Sharma',
      'Anil Desai',
      'Rajesh Mehta',
      'Ganesh Rao',
      'Mukesh Joshi'
    ];
    return names[index % names.length];
  }

  String _getUserRole(int index) {
    final roles = ['Manager', 'Supervisor', 'Labour', 'Manager', 'Labour', 'Supervisor', 'Labour', 'Labour'];
    return roles[index % roles.length];
  }

  String _getUserSite(int index) {
    final sites = ['Site A', 'Site B', 'Site C', 'Site A', 'Site B', 'Site C', 'Site A', 'Site D'];
    return sites[index % sites.length];
  }

  String _getUserMobile(int index) {
    return '98765432${10 + index}';
  }

  String _getUserStatus(int index) {
    return index % 5 == 0 ? 'Inactive' : 'Active';
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'Supervisor', child: Text('Supervisor')),
                  DropdownMenuItem(value: 'Labour', child: Text('Labour')),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Site',
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: const [
                  DropdownMenuItem(value: 'Site A', child: Text('Site A')),
                  DropdownMenuItem(value: 'Site B', child: Text('Site B')),
                  DropdownMenuItem(value: 'Site C', child: Text('Site C')),
                ],
                onChanged: (_) {},
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }
}