import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

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
  required String mobileNo,
  String? aadharNo,
}) async {
  final uid = _requireUid();

  await _client
      .from('users')
      .update({
        'name': name.trim(),
        'mobile_no': mobileNo.trim(),
        'aadhar_no': _cleanNullable(aadharNo),
      })
      .eq('id', uid);
}
static String? _cleanNullable(String? v) {
  if (v == null) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
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
    required int salary,
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
        'salary': salary, // ✅ FIXED
        'remaining_salary' : salary
      },
    );

    if (res.status != 200) {
      throw Exception('Failed to create user: ${res.data}');
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

// import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerPaymentService {
  static final _client = Supabase.instance.client;

  static String _uid() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }
    return user.id;
  }

  /// ===============================
  /// FETCH TEAM (SUPERVISOR + LABOUR)
  /// ===============================
  static Future<List<Map<String, dynamic>>> fetchTeam({
    String role = 'ALL', // SUPERVISOR | LABOUR | ALL
  }) async {
    final uid = _uid();

    // get logged-in manager org + venue
    final me = await _client
        .from('users')
        .select('organisation_id, venue_id')
        .eq('id', uid)
        .single();

    final organisationId = me['organisation_id'];
    final venueId = me['venue_id'];

    if (organisationId == null || venueId == null) {
      return [];
    }

    var query = _client
        .from('users')
        .select(
      'id, name, role, salary, due_advance, remaining_salary',
    )
        .eq('organisation_id', organisationId)
        .eq('venue_id', venueId)
        .eq('status', 'ACTIVE')
        .inFilter('role', ['SUPERVISOR', 'LABOUR']);

    if (role != 'ALL') {
      query = query.eq('role', role);
    }

    final res = await query
        .order('role')
        .order('name');

    return List<Map<String, dynamic>>.from(res);
  }

  /// ===============================
  /// MAKE PAYMENT
  /// ===============================
  static Future<void> makePayment({
    required String paidTo, // users.id (uuid)
    required int amount,
    required String paymentType, // SALARY | ADVANCE
    bool clearAdvance = false,
  }) async {
    final uid = _uid();

    final me = await _client
        .from('users')
        .select('organisation_id, venue_id')
        .eq('id', uid)
        .single();

    final organisationId = me['organisation_id'];
    final venueId = me['venue_id'];

    if (organisationId == null || venueId == null) {
      throw Exception('Manager is not assigned to a venue');
    }

    await _client.rpc(
      'process_payment',
      params: {
        'p_org_id': organisationId,
        'p_venue_id': venueId,
        'p_paid_by': uid,
        'p_paid_to': paidTo,
        'p_amount': amount,
        'p_payment_type': paymentType, // keep enum casing
        'p_clear_advance': clearAdvance,
      },
    );
  }
}

class LabourService {
  static Future<Map<String, dynamic>> fetchDashboard() async {
  final client = Supabase.instance.client;
  final uid = client.auth.currentUser!.id;

  final me = await client
      .from('users')
      .select('name,salary,remaining_salary,due_advance,venue_id')
      .eq('id', uid)
      .single();

  final venue = await client
      .from('venues')
      .select('name')
      .eq('id', me['venue_id'])
      .maybeSingle();

  final supervisor = await client
      .from('users')
      .select('name')
      .eq('venue_id', me['venue_id'])
      .eq('role', 'SUPERVISOR')
      .order('created_at')
      .limit(1)
      .maybeSingle();

  return {
    'name': me['name'],
    'venue_name': venue?['name'] ?? '-',
    'supervisor_name': supervisor?['name'] ?? '-',
    'salary': (me['salary'] ?? 0) as int,
    'due_advance': (me['due_advance'] ?? 0) as int,
    'remaining_salary': (me['remaining_salary'] ?? 0) as int,
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
class AdminTransactionsService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> fetchTransactions({
    DateTimeRange? range,
    String siteId = 'ALL',
    String type = 'ALL',
  }) async {
    final uid = _client.auth.currentUser!.id;

    // Admin org
    final admin = await _client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    var q = _client.from('transactions').select('''
      id,
      amount,
      payment_type,
      created_at,
      note,
      venue:venues(name),
      paid_by:users!transactions_paid_by_fkey(name),
      paid_to:users!transactions_paid_to_fkey(name)
    ''')
    .eq('organisation_id', admin['organisation_id']);

    if (siteId != 'ALL') {
      q = q.eq('venue_id', siteId);
    }

    if (type != 'ALL') {
      q = q.eq('payment_type', type);
    }

    if (range != null) {
      q = q
          .gte('created_at', range.start.toIso8601String())
          .lte('created_at', range.end.toIso8601String());
    }

    return List<Map<String, dynamic>>.from(
      await q.order('created_at', ascending: false),
    );
  }

  static Future<Map<String, dynamic>> fetchSummary() async {
    final uid = _client.auth.currentUser!.id;

    final admin = await _client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);

    final txns = await _client
        .from('transactions')
        .select('amount')
        .eq('organisation_id', admin['organisation_id'])
        .gte('created_at', start.toIso8601String());

    int total = 0;
    for (final t in txns) {
      total += (t['amount'] as num).toInt();
    }

    return {
      'total_payout': total,
      'count': txns.length,
    };
  }

  static Future<List<Map<String, dynamic>>> fetchSites() async {
    final uid = _client.auth.currentUser!.id;

    final admin = await _client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    return List<Map<String, dynamic>>.from(
      await _client
          .from('venues')
          .select('id,name')
          .eq('organisation_id', admin['organisation_id']),
    );
  }
}
class AdminPaymentService {
  static final _client = Supabase.instance.client;

  static String _uid() {
    final u = _client.auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.id;
  }

  /// ===============================
  /// FETCH TEAM BY SITE
  /// ===============================
  static Future<List<Map<String, dynamic>>> fetchTeam({
    required String venueId,
    String role = 'ALL',
  }) async {
    final uid = _uid();

    final admin = await _client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    var q = _client
        .from('users')
        .select('id,name,role,salary,due_advance')
        .eq('organisation_id', admin['organisation_id'])
        .eq('venue_id', venueId)
        .eq('status', 'ACTIVE')
        .inFilter('role', ['MANAGER', 'SUPERVISOR', 'LABOUR']);

    if (role != 'ALL') {
      q = q.eq('role', role);
    }

    final res = await q.order('role').order('name');
    return List<Map<String, dynamic>>.from(res);
  }

  /// ===============================
  /// MAKE PAYMENT (ADMIN)
  /// ===============================
  static Future<void> makePayment({
  required String venueId,
  required String paidTo, // users.id
  required int amount,
  required String paymentType, // SALARY | ADVANCE
  required int updatedDueAdvance,
}) async {
  final uid = _uid();

  // fetch admin organisation only
  final me = await _client
      .from('users')
      .select('organisation_id')
      .eq('id', uid)
      .single();

  final organisationId = me['organisation_id'];

  if (organisationId == null) {
    throw Exception('Admin organisation not found');
  }

  await _client.rpc(
    'process_payment',
    params: {
      'p_org_id': organisationId,
      'p_venue_id': venueId, // ✅ FROM UI
      'p_paid_by': uid,
      'p_paid_to': paidTo,
      'p_amount': amount,
      'p_payment_type': paymentType,
      'p_updated_due_advance': updatedDueAdvance, // ✅ EXPLICIT
    },
  );
}

}

class AdminDashboardService {
  static Future<Map<String, dynamic>> fetchDashboard() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    // Admin + organisation
    final admin = await client
        .from('users')
        .select('name, organisation_id')
        .eq('id', uid)
        .single();

    final orgId = admin['organisation_id'];

    // Counts
    final sites = await client
        .from('venues')
        .select('id')
        .eq('organisation_id', orgId);

    final managers = await client
        .from('users')
        .select('id')
        .eq('organisation_id', orgId)
        .eq('role', 'MANAGER');

    final labours = await client
        .from('users')
        .select('id')
        .eq('organisation_id', orgId)
        .eq('role', 'LABOUR');

    // Monthly payout
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final transactions = await client
        .from('transactions')
        .select('amount')
        .eq('organisation_id', orgId)
        .gte('created_at', startOfMonth.toIso8601String());

    int payout = 0;
    for (final t in transactions) {
      payout += (t['amount'] as num).toInt();
    }

    return {
      'admin_name': admin['name'],
      'total_sites': sites.length,
      'total_managers': managers.length,
      'total_labours': labours.length,
      'monthly_payout': payout,
    };
  }
}

class LabourTransactionService {
  static final _client = Supabase.instance.client;

  static String _uid() {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return user.id;
  }

  /// ===============================
  /// FETCH ALL TRANSACTIONS (SALARY + ADVANCE)
  /// ===============================
  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final uid = _uid();

    final res = await _client.from('transactions').select('''
      id,
      amount,
      payment_type,
      note,
      created_at,
      paid_by:users!transactions_paid_by_fkey(name, role)
    ''')
    .eq('paid_to', uid)
    .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  /// ===============================
  /// FETCH MONTHLY SUMMARY
  /// ===============================
  static Future<Map<String, int>> fetchMonthlySummary() async {
    final uid = _uid();

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final res = await _client
        .from('transactions')
        .select('amount, payment_type')
        .eq('paid_to', uid)
        .gte('created_at', startOfMonth.toIso8601String());

    int salary = 0;
    int advance = 0;

    for (final t in res) {
      final amt = (t['amount'] as num).toInt();
      if (t['payment_type'] == 'SALARY') salary += amt;
      if (t['payment_type'] == 'ADVANCE') advance += amt;
    }

    return {
      'salary': salary,
      'advance': advance,
      'balance': salary - advance,
    };
  }
}

/// ======================================================
/// FETCH CURRENT USER (ME)
/// ======================================================
class ProfileService {
  static Future<Map<String, dynamic>> fetchMe() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Not authenticated');
    }

    final me = await _client
        .from('users')
        .select('''
          id,
          name,
          role,
          status,
          mobile_no,
          email_id,
          salary,
          remaining_salary,
          due_advance,
          organisation_id,
          venue_id,
          organisations(name),
          venues(name, address)
        ''')
        .eq('id', user.id)
        .single();

    return {
      'id': me['id'],
      'name': me['name'],
      'role': me['role'],
      'status': me['status'],
      'mobile_no': me['mobile_no'],
      'email_id': me['email_id'],
      'salary': me['salary'],
      'remaining_salary': me['remaining_salary'],
      'due_advance': me['due_advance'],
      'organisation_id': me['organisation_id'],
      'venue_id': me['venue_id'],
      'org_name': me['organisations']?['name'],
      'venue_name': me['venues']?['name'],
      'venue_address': me['venues']?['address'],
    };
  }
}

