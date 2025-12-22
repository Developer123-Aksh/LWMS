import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme_provider.dart';
import '../auth/login_page.dart';

import 'labour_home.dart';
import 'labour_payments_page.dart';
import 'labour_profile_page.dart';

class LabourLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final int currentIndex; // ✅ SOURCE OF TRUTH

  const LabourLayout({
    super.key,
    required this.title,
    required this.child,
    required this.currentIndex,
  });

  Widget _pageByIndex(int index) {
    switch (index) {
      case 0:
        return const LabourDashboardPage();
      case 1:
        return const LabourPaymentsPage();
      case 2:
        return const LabourProfilePage();
      default:
        return const LabourDashboardPage();
    }
  }

  void _navigateFromBottomNav(BuildContext context, int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _pageByIndex(index)),
    );
  }

  void _navigateFromDrawer(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

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

      body: Padding(padding: const EdgeInsets.all(16), child: child),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex, // ✅ ALWAYS CORRECT
        onTap: (index) {
          if (index == currentIndex) return;
          _navigateFromBottomNav(context, index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Payments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Labour Panel')),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () =>
                  _navigateFromDrawer(context, const LabourDashboardPage()),
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Payments'),
              onTap: () =>
                  _navigateFromDrawer(context, const LabourPaymentsPage()),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () =>
                  _navigateFromDrawer(context, const LabourProfilePage()),
            ),
            const Divider(),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
