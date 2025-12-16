import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _client = Supabase.instance.client;

  static Future<Map<String, dynamic>?> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final res = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return res; // may be null and THAT IS OK
  }
}
