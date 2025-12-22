import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme_provider.dart';
import '../auth/login_page.dart';
import '../services/profile_service.dart';

import 'package:lwms/admin/admin_home.dart';
import 'package:lwms/manager/manager_dashboard_page.dart';
import 'package:lwms/supervisor/supervisor_dashboard_page.dart';
import 'package:lwms/labour/labour_home.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ProfileService.fetchMe(),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Error
        if (snapshot.hasError) {
          // Reset theme + force login
          context.read<ThemeProvider>().resetToGuest();
          return const LoginUIPage();
        }

        // ❌ No data
        if (!snapshot.hasData || snapshot.data == null) {
          context.read<ThemeProvider>().resetToGuest();
          return const LoginUIPage();
        }

        final role = snapshot.data!['role'];

        // ⚠️ Set role ONCE after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final theme = context.read<ThemeProvider>();

          switch (role) {
            case 'ADMIN':
              theme.setRole(UserRole.admin);
              break;
            case 'MANAGER':
              theme.setRole(UserRole.manager);
              break;
            case 'SUPERVISOR':
              theme.setRole(UserRole.supervisor);
              break;
            case 'LABOUR':
              theme.setRole(UserRole.labour);
              break;
            default:
              theme.resetToGuest();
          }
        });

        // 🧭 Route
        switch (role) {
          case 'ADMIN':
            return const AdminDashboardPage();
          case 'MANAGER':
            return const ManagerDashboardPage();
          case 'SUPERVISOR':
            return const SupervisorDashboardPage();
          case 'LABOUR':
            return const LabourDashboardPage();
          default:
            return const LoginUIPage();
        }
      },
    );
  }
}
