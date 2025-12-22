import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme_provider.dart';
import 'auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wehdpeovmnbjcnclmzua.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndlaGRwZW92bW5iamNuY2xtenVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3MzQ4NjgsImV4cCI6MjA4MTMxMDg2OH0.wGI0FTYstYn3kI-EjRhHeFQNYseQUeH4vOmPljlAWMY',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: AppTheme.lightTheme(theme.role),
      darkTheme: AppTheme.darkTheme(theme.role),
      home: const AuthGate(),
    );

  }
}
