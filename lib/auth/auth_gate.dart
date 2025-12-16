import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';
import '../theme_provider.dart';
import '../app_routes.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, authSnapshot) {
        final session =
            Supabase.instance.client.auth.currentSession;

        // 🔒 Not logged in
        if (session == null) {
          return const LoginUIPage();
        }

        // 🔓 Logged in → fetch profile
        return FutureBuilder<Map<String, dynamic>?>(
          future: UserService.fetchProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!profileSnapshot.hasData ||
                profileSnapshot.data == null) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'User profile not found',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final role = profileSnapshot.data!['role'];
            final themeProvider =
                context.read<ThemeProvider>();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              switch (role) {
                case 'ADMIN':
                  themeProvider.setRole(UserRole.admin);
                  Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
                  break;
                case 'MANAGER':
                  themeProvider.setRole(UserRole.manager);
                  Navigator.pushReplacementNamed(context, AppRoutes.managerHome);
                  break;
                case 'SUPERVISOR':
                  themeProvider.setRole(UserRole.supervisor);
                  Navigator.pushReplacementNamed(context, AppRoutes.supervisorHome);
                  break;
                case 'LABOUR':
                  themeProvider.setRole(UserRole.labour);
                  Navigator.pushReplacementNamed(context, AppRoutes.labourHome);
                  break;
                default:
                  // Handle unknown role
                  break;
              }
            });

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }
}
