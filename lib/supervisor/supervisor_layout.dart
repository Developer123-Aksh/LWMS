import 'package:flutter/material.dart';
import 'supervisor_dashboard_page.dart';
import 'supervisor_profile_page.dart';
import 'supervisor_labours_page.dart';
import 'supervisor_payments_page.dart';
import 'supervisor_transactions_page.dart';
import '../theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const SupervisorLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: 8),
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
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(
                      Icons.supervisor_account,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supervisor Panel',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Team Management',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupervisorDashboardPage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.groups,
                    title: 'Labours',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupervisorLaboursPage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.payments,
                    title: 'Payments',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupervisorPaymentsPage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.receipt,
                    title: 'Transactions',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupervisorTransactionsPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'My Profile',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupervisorProfilePage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      try {
                        // 1️⃣ Close drawer first (important on mobile)
                        Navigator.pop(context);

                        // 2️⃣ Sign out from Supabase
                        await Supabase.instance.client.auth.signOut();

                        // 3️⃣ Clear navigation stack and go to login
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login', // replace with your actual login route if different
                          (route) => false,
                        );
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
    );
  }
}
