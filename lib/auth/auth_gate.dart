import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../theme_provider.dart';
import '../auth/login_page.dart';
import 'role_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // 🔓 LOGGED OUT
        if (session == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ThemeProvider>().resetToGuest();
          });

          return const LoginUIPage();
        }

        // 🔐 LOGGED IN
        return const RoleRouter();
      },
    );
  }
}
