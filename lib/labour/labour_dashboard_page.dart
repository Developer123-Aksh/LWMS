import 'package:flutter/material.dart';
import 'labour_home.dart';
import 'labour_payments_page.dart';
import 'labour_profile_page.dart';
import '../theme_provider.dart';
import 'package:provider/provider.dart';

class LabourHome extends StatefulWidget {
  const LabourHome({super.key});

  @override
  State<LabourHome> createState() => _LabourHomeState();
}

class _LabourHomeState extends State<LabourHome> {
  int _index = 0;

  final pages = const [
    LabourDashboardPage(),
    LabourPaymentsPage(),
    LabourProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: isDark 
            ? Theme.of(context).colorScheme.surface 
            : Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(
              Icons.dashboard,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(
              Icons.payments,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}