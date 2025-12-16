import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterOrganisationUIPage extends StatefulWidget {
  const RegisterOrganisationUIPage({super.key});

  @override
  State<RegisterOrganisationUIPage> createState() =>
      _RegisterOrganisationUIPageState();
}

class _RegisterOrganisationUIPageState
    extends State<RegisterOrganisationUIPage> {
  final _orgName = TextEditingController();
  final _orgAddress = TextEditingController();
  final _adminName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Organisation')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Register Your Organisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form fields go here
                    TextField(
                      controller: _orgName,
                      decoration: InputDecoration(
                        labelText: 'Organisation Name',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _orgAddress,
                      decoration: InputDecoration(
                        labelText: 'Organisation Address',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _adminName,
                      decoration: InputDecoration(
                        labelText: 'Admin Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _mobile,
                      decoration: InputDecoration(
                        labelText: 'Mobile',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registerOrganisation,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Register Organisation',
                                style: TextStyle(fontSize: 16),
                              ),
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

  Future<void> _registerOrganisation() async {
    setState(() {
      _loading = true;
    });
    final supabase = Supabase.instance.client;

    try {
      final authRes = await supabase.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
      );
      final userId = authRes.user?.id;
      if (userId == null) {
        throw Exception('Failed to create user');
      }
      final orgRes = await supabase
          .from('organisations')
          .insert({
            'name': _orgName.text.trim(),
            'address': _orgAddress.text.trim(),
            'email_id': _email.text.trim(),
            'mobile_no': _mobile.text.trim(),
          })
          .select()
          .single();
      final orgId = orgRes['id'];
      await supabase.from('users').insert({
        'id': userId,
        'name': _adminName.text.trim(),
        'email_id': _email.text.trim(),
        'mobile_no': _mobile.text.trim(),
        'role': 'ADMIN',
        'organisation_id': orgId,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }

      // After successful registration, navigate or show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organisation registered successfully!')),
      );
    }
  }
}
