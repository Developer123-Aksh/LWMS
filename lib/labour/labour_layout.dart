import 'package:flutter/material.dart';
import 'package:lwms/auth/login_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme_provider.dart';
import 'labour_home.dart';
import 'labour_payments_page.dart';
import 'labour_profile_page.dart';


class LabourLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const LabourLayout({
    super.key,
    required this.title,
    required this.child,
  });

  int _currentIndex() {
    switch (title) {
      case 'Dashboard':
        return 0;
      case 'Payments':
        return 1;
      case 'My Profile':
        return 2;
      default:
        return 0;
    }
  }

  void _navigate(BuildContext context, int index) {
    Widget page;

    switch (index) {
      case 0:
        page = const LabourDashboardPage();
        break;
      case 1:
        page = const LabourPaymentsPage();
        break;
      case 2:
        page = const LabourProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // ================= APP BAR =================
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),

      // ================= BODY =================
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: child,
              ),
            );
          },
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(),
        onTap: (index) {
          if (index == _currentIndex()) return;
          _navigate(context, index);
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
