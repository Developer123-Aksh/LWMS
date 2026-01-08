import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterOrgPage extends StatefulWidget {
  const RegisterOrgPage({super.key});

  @override
  State<RegisterOrgPage> createState() => _RegisterOrgPageState();
}

class _RegisterOrgPageState extends State<RegisterOrgPage> {
  final _orgCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _orgCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerOrganisation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;

      // 1️⃣ Create auth user (ADMIN)
      final authRes = await client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      final user = authRes.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      // 2️⃣ Create organisation
      final org = await client
          .from('organisations')
          .insert({
            'name': _orgCtrl.text.trim(),
            'address': _addressCtrl.text.trim(),
            'mobile_no': _mobileCtrl.text.trim(),
            'status': 'ACTIVE',
          })
          .select('id')
          .single();

      final orgId = org['id'];

      // 3️⃣ Create admin profile
      await client.from('users').insert({
        'id': user.id,
        'name': _nameCtrl.text.trim(),
        'email_id': _emailCtrl.text.trim(),
        'mobile_no': _mobileCtrl.text.trim(),
        'role': 'ADMIN',
        'organisation_id': orgId,
        'status': 'ACTIVE',
      });

      // 4️⃣ Explicit logout
      // AuthGate will route to Login
      await client.auth.signOut();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Organisation')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Organisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _orgCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Organisation Name',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Admin Name',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Admin Email',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _mobileCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registerOrganisation,
                        child: _loading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}
