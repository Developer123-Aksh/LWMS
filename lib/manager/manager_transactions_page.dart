import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manager_layout.dart';

class ManagerTransactionsPage extends StatefulWidget {
  const ManagerTransactionsPage({super.key});

  @override
  State<ManagerTransactionsPage> createState() =>
      _ManagerTransactionsPageState();
}

class _ManagerTransactionsPageState extends State<ManagerTransactionsPage> {
  late Future<List<Map<String, dynamic>>> _txFuture;

  @override
  void initState() {
    super.initState();
    _txFuture = _fetchTransactions();
  }

  // ================= FETCH TRANSACTIONS =================

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    // 1️⃣ Fetch organisation of logged-in manager
    final me = await client
        .from('users')
        .select('organisation_id')
        .eq('id', user.id)
        .single();

    // 2️⃣ Fetch transactions (SAFE column-based joins)
    final res = await client.from('transactions').select('''
      id,
      created_at,
      amount,
      payment_type,
      note,
      users_paid_by:users!paid_by(name),
      users_paid_to:users!paid_to(name)
    ''')
    .eq('organisation_id', me['organisation_id'])
    .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'Transactions',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _txFuture,
        builder: (context, snapshot) {
          // ⛔ STOP infinite spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ SHOW REAL ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          final txs = snapshot.data!;
          final totalPaid =
              txs.fold<int>(0, (sum, t) => sum + (t['amount'] as int));

          return Column(
            children: [
              _summaryRow(context, totalPaid, txs.length),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: txs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _transactionTile(context, txs[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryRow(BuildContext context, int totalPaid, int count) {
    return Row(
      children: [
        _summaryCard(
          context,
          title: 'Total Paid',
          value: '₹ $totalPaid',
          icon: Icons.payments,
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          context,
          title: 'Transactions',
          value: '$count',
          icon: Icons.receipt_long,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TRANSACTION TILE =================

  Widget _transactionTile(
      BuildContext context, Map<String, dynamic> tx) {
    final paidTo = tx['users_paid_to']?['name'] ?? 'Unknown';
    final date = DateTime.parse(tx['created_at']).toLocal();

    return ListTile(
      leading: const Icon(Icons.payments),
      title: Text(
        paidTo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        '₹ ${tx['amount']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_paymentType(tx['payment_type'])),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      onTap: () => _showDetails(context, tx),
    );
  }

  // ================= DETAILS =================

  void _showDetails(BuildContext context, Map<String, dynamic> tx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Paid By', tx['users_paid_by']?['name'] ?? '-'),
            _row('Paid To', tx['users_paid_to']?['name'] ?? '-'),
            _row('Amount', '₹ ${tx['amount']}'),
            _row('Type', _paymentType(tx['payment_type'])),
            if (tx['note'] != null && tx['note'].toString().isNotEmpty)
              _row('Note', tx['note']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }

  // ================= HELPERS =================

  String _paymentType(String? type) {
    switch (type) {
      case 'SALARY':
        return 'Salary';
      case 'ADVANCE':
        return 'Advance';
      default:
        return type ?? 'Unknown';
    }
  }
}
