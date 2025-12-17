import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _client = Supabase.instance.client;

/// ======================================================
/// COMMON HELPERS
/// ======================================================
String _requireUid() {
  final user = _client.auth.currentUser;
  if (user == null) {
    throw Exception('Not authenticated');
  }
  return user.id;
}

String _requireAccessToken() {
  final session = _client.auth.currentSession;
  if (session == null) {
    throw Exception('No active session');
  }
  return session.accessToken;
}

String? _cleanNullable(String? v) {
  if (v == null) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

/// ======================================================
/// ADMIN SERVICE
/// ======================================================
class AdminService {
  static Future<Map<String, String>> fetchAdminHeader() async {
    final uid = _requireUid();

    final res = await _client
        .from('users')
        .select('name, organisations(name)')
        .eq('id', uid)
        .single();

    return {'adminName': res['name'], 'orgName': res['organisations']['name']};
  }

  /// 🔐 ADMIN RESET PASSWORD (ANY USER IN ORG)
  static Future<void> resetUserPassword({
    required String targetUserId,
    required String newPassword,
  }) async {
    final token = _requireAccessToken();

    final res = await _client.functions.invoke(
      'reset-user-password',
      headers: {'Authorization': 'Bearer $token'},
      body: {'target_user_id': targetUserId, 'new_password': newPassword},
    );

    if (res.status != 200) {
      throw Exception(res.data);
    }
  }
}

/// ======================================================
/// MANAGER SERVICE
/// ======================================================
class ManagerService {
  /// ---------- PROFILE ----------
  static Future<Map<String, dynamic>> fetchProfile() async {
    final uid = _requireUid();

    final me = await _client.from('users').select('*').eq('id', uid).single();

    final org = await _client
        .from('organisations')
        .select('name')
        .eq('id', me['organisation_id'])
        .single();

    Map<String, dynamic>? venue;
    if (me['venue_id'] != null) {
      venue = await _client
          .from('venues')
          .select('name,address')
          .eq('id', me['venue_id'])
          .maybeSingle();
    }

    return {
      ...me,
      'org_name': org['name'],
      'venue_name': venue?['name'],
      'venue_address': venue?['address'],
    };
  }

  static Future<void> updateProfile({
    required String name,
    required String mobile,
    String? aadhar,
  }) async {
    final uid = _requireUid();

    await _client
        .from('users')
        .update({
          'name': name.trim(),
          'mobile_no': mobile.trim(),
          'aadhar_no': _cleanNullable(aadhar),
        })
        .eq('id', uid);
  }

  /// ---------- TEAM ----------
  static Future<List<Map<String, dynamic>>> fetchTeamMembers({
    String role = 'ALL',
    String status = 'ALL',
  }) async {
    final uid = _requireUid();

    final me = await _client
        .from('users')
        .select('organisation_id, venue_id')
        .eq('id', uid)
        .single();

    if (me['venue_id'] == null) return [];

    var q = _client
        .from('users')
        .select('id,name,mobile_no,role,status')
        .eq('organisation_id', me['organisation_id'])
        .eq('venue_id', me['venue_id'])
        .inFilter('role', ['LABOUR', 'SUPERVISOR']);

    if (role != 'ALL') q = q.eq('role', role);
    if (status != 'ALL') q = q.eq('status', status);

    return await q.order('name');
  }

  /// ---------- CREATE USER ----------
  static Future<void> createUserByManager({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required String role,
  }) async {
    if (role != 'LABOUR' && role != 'SUPERVISOR') {
      throw Exception('Manager can only add Labour or Supervisor');
    }

    final uid = _requireUid();

    final me = await _client
        .from('users')
        .select('organisation_id, venue_id')
        .eq('id', uid)
        .single();

    if (me['venue_id'] == null) {
      throw Exception('Manager has no venue assigned');
    }

    final token = _requireAccessToken();

    final res = await _client.functions.invoke(
      'create-user',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'mobile_no': mobile.trim(),
        'role': role,
        'organisation_id': me['organisation_id'],
        'venue_id': me['venue_id'],
      },
    );

    if (res.status != 200) {
      throw Exception(res.data);
    }
  }

  /// 🔐 MANAGER RESET PASSWORD (ONLY SAME VENUE)
  static Future<void> resetUserPassword({
    required String targetUserId,
    required String newPassword,
  }) async {
    final token = _requireAccessToken();

    final res = await _client.functions.invoke(
      'reset-user-password',
      headers: {'Authorization': 'Bearer $token'},
      body: {'target_user_id': targetUserId, 'new_password': newPassword},
    );

    if (res.status != 200) {
      throw Exception(res.data);
    }
  }
}

/// ======================================================
/// SUPERVISOR SERVICE
/// ======================================================
class SupervisorService {
  /// ---------------- PROFILE ----------------
  static Future<Map<String, dynamic>> fetchProfile() async {
    final uid = _requireUid();

    final me = await _client
        .from('users')
        .select(
          'id,name,email_id,mobile_no,role,status,created_at,organisation_id,venue_id,aadhar_no',
        )
        .eq('id', uid)
        .single();

    final org = await _client
        .from('organisations')
        .select('name')
        .eq('id', me['organisation_id'])
        .single();

    Map<String, dynamic>? venue;
    if (me['venue_id'] != null) {
      venue = await _client
          .from('venues')
          .select('name,address')
          .eq('id', me['venue_id'])
          .maybeSingle();
    }

    return {
      ...me,
      'org_name': org['name'],
      'venue_name': venue?['name'],
      'venue_address': venue?['address'],
    };
  }

  /// ---------------- TEAM (VIEW ONLY) ----------------
  /// Labours + Supervisors in same venue
  static Future<List<Map<String, dynamic>>> fetchTeam() async {
    final uid = _requireUid();

    final me = await _client
        .from('users')
        .select('organisation_id, venue_id')
        .eq('id', uid)
        .single();

    if (me['venue_id'] == null) return [];

    return await _client
        .from('users')
        .select('id,name,mobile_no,role,status')
        .eq('organisation_id', me['organisation_id'])
        .eq('venue_id', me['venue_id'])
        .inFilter('role', ['LABOUR', 'SUPERVISOR'])
        .order('name');
  }

  /// ---------------- TRANSACTIONS (VIEW ONLY) ----------------
  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final uid = _requireUid();

    final me = await _client
        .from('users')
        .select('organisation_id, venue_id')
        .eq('id', uid)
        .single();

    if (me['venue_id'] == null) return [];

    return await _client
        .from('transactions')
        .select('''
      id,
      amount,
      payment_type,
      status,
      created_at,
      note,
      paid_by:users!transactions_paid_by_fkey(name),
      paid_to:users!transactions_paid_to_fkey(name)
    ''')
        .eq('organisation_id', me['organisation_id'])
        .eq('venue_id', me['venue_id'])
        .order('created_at', ascending: false);
  }

  /// ---------------- UPDATE PROFILE ----------------
  static Future<void> updateProfile({
    required String name,
    required String mobile,
    String? aadhar,
  }) async {
    final uid = _requireUid();

    await _client
        .from('users')
        .update({
          'name': name.trim(),
          'mobile_no': mobile.trim(),
          'aadhar_no': _cleanNullable(aadhar),
        })
        .eq('id', uid);
  }
}

/// ======================================================
/// LABOUR SERVICE
/// ======================================================

// class LabourService {
//   static Future<Map<String, dynamic>> fetchDashboard() async {
//   final client = Supabase.instance.client;
//   final uid = client.auth.currentUser!.id;

//   // 1️⃣ Logged-in labour
//   final me = await client
//       .from('users')
//       .select('name, salary, venue_id')
//       .eq('id', uid)
//       .single();

//   // 2️⃣ Venue
//   final venue = await client
//       .from('venues')
//       .select('name')
//       .eq('id', me['venue_id'])
//       .maybeSingle();

//   // 3️⃣ Supervisor from SAME VENUE
//   final supervisor = await client
//       .from('users')
//       .select('name')
//       .eq('venue_id', me['venue_id'])
//       .eq('role', 'SUPERVISOR')
//       .order('created_at')
//       .limit(1)
//       .maybeSingle();

//   // 4️⃣ Current month range
//   final now = DateTime.now();
//   final startOfMonth = DateTime(now.year, now.month, 1);

//   // 5️⃣ Advances this month
//   final advances = await client
//       .from('transactions')
//       .select('amount')
//       .eq('paid_to', uid)
//       .eq('payment_type', 'ADVANCE')
//       .gte('created_at', startOfMonth.toIso8601String());

//   int totalAdvance = 0;
//   for (final a in advances) {
//     totalAdvance += (a['amount'] as num).toInt();
//   }

//   final salary = (me['salary'] ?? 0) as int;

//   return {
//     'name': me['name'],
//     'venue_name': venue?['name'] ?? '-',
//     'supervisor_name': supervisor?['name'] ?? '-',
//     'salary': salary,
//     'total_advance': totalAdvance,
//     'balance_due': salary - totalAdvance,
//   };
// }
//   /// 🔧 Used by profile edit
//   static Future<void> updateProfile({
//     required String name,
//     required String mobile,
//     String? aadhar,
//   }) async {
//     final client = Supabase.instance.client;
//     final user = client.auth.currentUser;

//     if (user == null) {
//       throw Exception('Not authenticated');
//     }

//     await client.from('users').update({
//       'name': name.trim(),
//       'mobile_no': mobile.trim(),
//       'aadhar_no': aadhar?.trim().isEmpty == true ? null : aadhar?.trim(),
//     }).eq('id', user.id);
//   }

//   /// 🔍 Used by profile page
//   static Future<Map<String, dynamic>> fetchProfile() async {
//     final client = Supabase.instance.client;
//     final user = client.auth.currentUser;

//     if (user == null) {
//       throw Exception('Not authenticated');
//     }

//     final me = await client
//         .from('users')
//         .select(
//           'id,name,role,status,mobile_no,aadhar_no,created_at,organisation_id,venue_id',
//         )
//         .eq('id', user.id)
//         .single();

//     final org = await client
//         .from('organisations')
//         .select('name')
//         .eq('id', me['organisation_id'])
//         .maybeSingle();

//     Map<String, dynamic>? venue;
//     if (me['venue_id'] != null) {
//       venue = await client
//           .from('venues')
//           .select('name,address')
//           .eq('id', me['venue_id'])
//           .maybeSingle();
//     }

//     return {
//       ...me,
//       'org_name': org?['name'] ?? '-',
//       'venue_name': venue?['name'] ?? 'Not Assigned',
//       'venue_address': venue?['address'] ?? '',
//     };
//   }
//   static Future<List<Map<String, dynamic>>> fetchPayments() async {
//   final client = Supabase.instance.client;
//   final uid = client.auth.currentUser!.id;

//   return await client.from('transactions').select('''
//     id,
//     amount,
//     payment_type,
//     created_at,
//     note,
//     paid_by:users!transactions_paid_by_fkey(name)
//   ''')
//   .eq('paid_to', uid)
//   .order('created_at', ascending: false);
// }

// }//TODO : Add 
class LabourService {
  static Future<Map<String, dynamic>> fetchDashboard() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    // 1️⃣ Logged-in labour
    final me = await client
        .from('users')
        .select('name, salary, venue_id')
        .eq('id', uid)
        .single();

    // 2️⃣ Venue
    final venue = await client
        .from('venues')
        .select('name')
        .eq('id', me['venue_id'])
        .maybeSingle();

    // 3️⃣ Supervisor from SAME VENUE
    final supervisor = await client
        .from('users')
        .select('name')
        .eq('venue_id', me['venue_id'])
        .eq('role', 'SUPERVISOR')
        .order('created_at')
        .limit(1)
        .maybeSingle();

    // 4️⃣ Current month range
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // 5️⃣ Advances this month
    final advances = await client
        .from('transactions')
        .select('amount')
        .eq('paid_to', uid)
        .eq('payment_type', 'ADVANCE')
        .gte('created_at', startOfMonth.toIso8601String());

    int totalAdvance = 0;
    for (final a in advances) {
      totalAdvance += (a['amount'] as num).toInt();
    }

    final salary = (me['salary'] ?? 0) as int;

    return {
      'name': me['name'],
      'venue_name': venue?['name'] ?? '-',
      'supervisor_name': supervisor?['name'] ?? '-',
      'salary': salary,
      'total_advance': totalAdvance,
      'balance_due': salary - totalAdvance,
    };
  }

  /// 🔧 Used by profile edit
  static Future<void> updateProfile({
    required String name,
    required String mobile,
    String? aadhar,
  }) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Not authenticated');
    }

    await client.from('users').update({
      'name': name.trim(),
      'mobile_no': mobile.trim(),
      'aadhar_no': aadhar?.trim().isEmpty == true ? null : aadhar?.trim(),
    }).eq('id', user.id);
  }

  /// 🔍 Used by profile page
  static Future<Map<String, dynamic>> fetchProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Not authenticated');
    }

    final me = await client
        .from('users')
        .select(
          'id,name,role,status,mobile_no,aadhar_no,created_at,organisation_id,venue_id',
        )
        .eq('id', user.id)
        .single();

    final org = await client
        .from('organisations')
        .select('name')
        .eq('id', me['organisation_id'])
        .maybeSingle();

    Map<String, dynamic>? venue;
    if (me['venue_id'] != null) {
      venue = await client
          .from('venues')
          .select('name,address')
          .eq('id', me['venue_id'])
          .maybeSingle();
    }

    return {
      ...me,
      'org_name': org?['name'] ?? '-',
      'venue_name': venue?['name'] ?? 'Not Assigned',
      'venue_address': venue?['address'] ?? '',
    };
  }

  /// 💰 Fetch payments for labour
  static Future<List<Map<String, dynamic>>> fetchPayments() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final results = await client.from('transactions').select('''
      id,
      amount,
      payment_type,
      created_at,
      note,
      paid_by:users!transactions_paid_by_fkey(name)
    ''')
    .eq('paid_to', uid)
    .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(results);
  }

  /// 📊 Fetch payment summary for current month
  static Future<Map<String, dynamic>> fetchPaymentSummary() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Get all transactions for current month
    final transactions = await client
        .from('transactions')
        .select('amount, payment_type')
        .eq('paid_to', uid)
        .gte('created_at', startOfMonth.toIso8601String());

    int totalEarned = 0;
    int totalAdvances = 0;
    int advanceCount = 0;

    for (final t in transactions) {
      final amount = (t['amount'] as num).toInt();
      totalEarned += amount;
      
      if (t['payment_type'] == 'ADVANCE') {
        totalAdvances += amount;
        advanceCount++;
      }
    }

    final balance = totalEarned - totalAdvances;

    return {
      'total_earned': totalEarned,
      'total_advances': totalAdvances,
      'advance_count': advanceCount,
      'balance': balance,
    };
  }
}