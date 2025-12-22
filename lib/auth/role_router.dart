import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme_provider.dart';
import '../services/profile_service.dart';
import '../auth/login_page.dart';

import '../admin/admin_home.dart';
import '../manager/manager_dashboard_page.dart';
import '../supervisor/supervisor_dashboard_page.dart';
import '../labour/labour_home.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ProfileService.fetchMe(),
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!s.hasData || s.hasError) {
          return const LoginUIPage();
        }

        final role = s.data!['role'];
        final theme = context.read<ThemeProvider>();

        // Set role ONCE, safely
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
