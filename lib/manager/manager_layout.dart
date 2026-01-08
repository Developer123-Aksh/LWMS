import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme_provider.dart';

// pages
import 'manager_dashboard_page.dart';
import 'manager_labours_page.dart';
import 'manager_payments_page.dart';
import 'manager_transactions_page.dart';
import 'manager_profile_page.dart';

class ManagerLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const ManagerLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 🔧 MUST use watch so icon updates when theme toggles
    final themeProvider = context.watch<ThemeProvider>();
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.badge, size: 32),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Manager Panel',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Site Management',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
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
                    page: const ManagerDashboardPage(),
                  ),
                  _item(
                    context,
                    icon: Icons.groups,
                    title: 'Team Members',
                    page: const ManagerTeamPage(),
                  ),
                  _item(
                    context,
                    icon: Icons.payments,
                    title: 'Payments',
                    page: const ManagerPaymentsPage(),
                  ),
                  _item(
                    context,
                    icon: Icons.receipt,
                    title: 'Transactions',
                    page: const ManagerTransactionsPage(),
                  ),
                  const Divider(height: 32),
                  _item(
                    context,
                    icon: Icons.person,
                    title: 'My Profile',
                    page: const ManagerProfilePage(),
                  ),

                  // ================= LOGOUT (CORRECT) =================
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      try {
                        // Close drawer first
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
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
        // Close drawer
        Navigator.of(context).pop();

        // Replace current page inside manager flow
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
