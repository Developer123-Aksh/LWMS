import 'package:supabase_flutter/supabase_flutter.dart';

/// ======================================================
/// ADMIN SERVICE
/// ======================================================
class AdminService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch admin name + organisation name
  static Future<Map<String, String>> fetchAdminHeader() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final res = await _client
        .from('users')
        .select('name, organisations(name)')
        .eq('id', user.id)
        .single();

    return {
      'adminName': res['name'] as String,
      'orgName': res['organisations']['name'] as String,
    };
  }

  /// Dashboard counts
  static Future<Map<String, int>> fetchCounts() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final orgRes = await _client
        .from('users')
        .select('organisation_id')
        .eq('id', user.id)
        .single();

    final orgId = orgRes['organisation_id'];

    final managers = await _client
        .from('users')
        .select('id')
        .eq('organisation_id', orgId)
        .eq('role', 'MANAGER');

    final supervisors = await _client
        .from('users')
        .select('id')
        .eq('organisation_id', orgId)
        .eq('role', 'SUPERVISOR');

    final labours = await _client
        .from('users')
        .select('id')
        .eq('organisation_id', orgId)
        .eq('role', 'LABOUR');

    return {
      'managers': managers.length,
      'supervisors': supervisors.length,
      'labours': labours.length,
    };
  }
}

/// ======================================================
/// MANAGER SERVICE
/// ======================================================
class ManagerService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Map<String, dynamic>> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Auth user is null');

    final userRes = await _client
        .from('users')
        .select(
          'name, email_id, mobile_no, aadhar_no, role, status, organisation_id, venue_id, created_at',
        )
        .eq('id', user.id)
        .single();

    // Organisation
    String orgName = '-';
    if (userRes['organisation_id'] != null) {
      final org = await _client
          .from('organisations')
          .select('name')
          .eq('id', userRes['organisation_id'])
          .maybeSingle();

      if (org != null) orgName = org['name'] ?? '-';
    }

    // Venue
    String venueName = 'Not Assigned';
    String venueAddress = '';
    if (userRes['venue_id'] != null) {
      final venue = await _client
          .from('venues')
          .select('name, address')
          .eq('id', userRes['venue_id'])
          .maybeSingle();

      if (venue != null) {
        venueName = venue['name'] ?? 'Not Assigned';
        venueAddress = venue['address'] ?? '';
      }
    }

    return {
      ...Map<String, dynamic>.from(userRes),
      'org_name': orgName,
      'venue_name': venueName,
      'venue_address': venueAddress,
    };
  }

  static Future<void> updateProfile({
    required String name,
    required String mobile,
    required String aadhar,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Auth user is null');

    await _client.from('users').update({
      'name': name,
      'mobile_no': mobile,
      'aadhar_no': aadhar.trim().isEmpty ? null : aadhar.trim(),
    }).eq('id', user.id);
  }
}

/// ======================================================
/// SUPERVISOR SERVICE
/// ======================================================
class SupervisorService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Map<String, dynamic>> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Auth user is null');

    final userRes = await _client
        .from('users')
        .select(
          'name, email_id, mobile_no, aadhar_no, role, status, created_at, organisation_id, venue_id',
        )
        .eq('id', user.id)
        .single();

    // Organisation
    String orgName = '-';
    if (userRes['organisation_id'] != null) {
      final org = await _client
          .from('organisations') // ✅ FIXED
          .select('name')
          .eq('id', userRes['organisation_id'])
          .maybeSingle();

      if (org != null) orgName = org['name'] ?? '-';
    }

    // Venue
    String venueName = 'Not Assigned';
    String venueAddress = '';
    if (userRes['venue_id'] != null) {
      final venue = await _client
          .from('venues')
          .select('name, address')
          .eq('id', userRes['venue_id'])
          .maybeSingle();

      if (venue != null) {
        venueName = venue['name'] ?? 'Not Assigned';
        venueAddress = venue['address'] ?? '';
      }
    }

    return {
      ...Map<String, dynamic>.from(userRes),
      'org_name': orgName,
      'venue_name': venueName,
      'venue_address': venueAddress,
    };
  }

  static Future<void> updateProfile({
    required String name,
    required String mobile,
    required String aadhar,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Auth user is null');

    await _client.from('users').update({
      'name': name,
      'mobile_no': mobile,
      'aadhar_no': aadhar.trim().isEmpty ? null : aadhar.trim(),
    }).eq('id', user.id);
  }
}


class LabourService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ================= FETCH LABOUR PROFILE =================

  static Future<Map<String, dynamic>> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Auth user is null');

    final res = await _client
        .from('users')
        .select('''
          name,
          email_id,
          mobile_no,
          aadhar_no,
          role,
          status,
          created_at,
          salary,
          organisation_id,
          venue_id
        ''')
        .eq('id', user.id)
        .single();

    // Organisation
    String orgName = '-';
    if (res['organisation_id'] != null) {
      final org = await _client
          .from('organisations')
          .select('name')
          .eq('id', res['organisation_id'])
          .maybeSingle();

      if (org != null) orgName = org['name'] ?? '-';
    }

    // Venue (Site)
    String venueName = 'Not Assigned';
    String venueAddress = '';
    if (res['venue_id'] != null) {
      final venue = await _client
          .from('venues')
          .select('name, address')
          .eq('id', res['venue_id'])
          .maybeSingle();

      if (venue != null) {
        venueName = venue['name'] ?? 'Not Assigned';
        venueAddress = venue['address'] ?? '';
      }
    }

    return {
      ...Map<String, dynamic>.from(res),
      'org_name': orgName,
      'venue_name': venueName,
      'venue_address': venueAddress,
    };
  }
}

