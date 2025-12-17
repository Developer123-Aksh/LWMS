import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  static final _client = Supabase.instance.client;

  static String get _uid {
    final u = _client.auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.id;
  }

  // ================= CREATE PAYMENT =================

  static Future<void> createPayment({
    required String paidToUserId,
    required int amount,
    required int paymentType,
    String? venueId,
    String? note,
  }) async {
    // 1️⃣ Get organisation of manager
    final user = await _client
        .from('users')
        .select('organisation_id')
        .eq('id', _uid)
        .single();

    final orgId = user['organisation_id'];

    // 2️⃣ Insert transaction
    await _client.from('transactions').insert({
      'organisation_id': orgId,
      'paid_by': _uid,
      'paid_to': paidToUserId,
      'venue_id': venueId,
      'amount': amount,
      'payment_type': paymentType,
      'note': note,
      'status': 1,
    });
  }

  // ================= FETCH TRANSACTIONS =================

  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final user = await _client
        .from('users')
        .select('organisation_id')
        .eq('id', _uid)
        .single();

    return await _client
        .from('transactions')
        .select('''
          id,
          amount,
          payment_type,
          created_at,
          note,
          paid_to:users!transactions_paid_to_fkey(name),
          paid_by:users!transactions_paid_by_fkey(name)
        ''')
        .eq('organisation_id', user['organisation_id'])
        .order('created_at', ascending: false);
  }
}
