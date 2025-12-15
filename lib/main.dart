import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'labour/labour_dashboard_page.dart';
// import 'admin/admin_home.dart';
// import 'manager/manager_dashboard_page.dart';
// import 'supervisor/supervisor_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // Set the user role - this would come from login/auth
          const currentUserRole = UserRole.labour;
          
          return MaterialApp(
            title: 'Construction Management',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme(currentUserRole),
            darkTheme: AppTheme.darkTheme(currentUserRole),
            home:  const LabourHome(),
          );
        },
      ),
    );
  }
}

// For other user types, simply change the UserRole:
// Manager: const currentUserRole = UserRole.manager;
// Supervisor: const currentUserRole = UserRole.supervisor;
// Labour: const currentUserRole = UserRole.labour;