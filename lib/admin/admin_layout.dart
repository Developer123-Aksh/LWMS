import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme_provider.dart';

// pages
import 'admin_home.dart';
import 'admin_sites_page.dart';
import 'admin_users_page.dart';
import 'admin_profile_page.dart';
import 'admin_payment_page.dart';
import 'admin_transection_page.dart';


class AdminLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AdminLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.admin_panel_settings, size: 32),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _item(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    page: const AdminDashboardPage(),
                  ),
                  _item(
                    context,
                    icon: Icons.location_city,
                    title: 'Sites',
                    page: const AdminSitesPage(),
                  ),
                  _item(
                    context,
                    icon: Icons.payment,
                    title: 'Make Payment',
                    page: const AdminPaymentsPage(),
                  ),
                  _item(
                    context,
                    icon: Icons.people,
                    title: 'Users',
                    page: const AdminUsersPage(),
                  ),
                  _item(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Transactions',
                    page: const AdminTransactionsPage(),
                  ),
                  const Divider(height: 32),
                  _item(
                    context,
                    icon: Icons.person,
                    title: 'My Profile',
                    page: const AdminProfilePage(),
                  ),

                  /// ================= LOGOUT (FIXED) =================
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      try {
                        // Close drawer if present
                        Navigator.of(context).pop();

                        // ONLY sign out
                        await Supabase.instance.client.auth.signOut();
                        // ❌ no navigation here
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logout failed: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
