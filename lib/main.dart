import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme_provider.dart';
import 'auth/auth_gate.dart';
import 'auth/login_page.dart';
import 'auth/register_org_page.dart';
import 'app_routes.dart';
import 'admin/admin_home.dart';
import 'manager/manager_dashboard_page.dart';
import 'supervisor/supervisor_dashboard_page.dart';
import 'labour/labour_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wehdpeovmnbjcnclmzua.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndlaGRwZW92bW5iamNuY2xtenVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3MzQ4NjgsImV4cCI6MjA4MTMxMDg2OH0.wGI0FTYstYn3kI-EjRhHeFQNYseQUeH4vOmPljlAWMY',
  );
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
          final role =
              themeProvider.role ?? UserRole.guest;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme(role),
            darkTheme: AppTheme.darkTheme(role),
            home: const AuthGate(),
            routes: {
              AppRoutes.login: (_) => const LoginUIPage(),
              AppRoutes.registerOrg: (_) =>
                  const RegisterOrganisationUIPage(),
              AppRoutes.adminHome: (_) =>
                  const AdminDashboardPage(),
              AppRoutes.managerHome: (_) =>
                  const ManagerDashboardPage(),
              AppRoutes.supervisorHome: (_) =>
                  const SupervisorDashboardPage(),
              AppRoutes.labourHome: (_) =>
                  const LabourHome(),
            },
          );
        },
      ),
    );
  }
}
