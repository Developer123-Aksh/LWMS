import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'labour_layout.dart';
import '../services/profile_service.dart';

class LabourPaymentsPage extends StatefulWidget {
  const LabourPaymentsPage({super.key});

  @override
  State<LabourPaymentsPage> createState() => _LabourPaymentsPageState();
}

class _LabourPaymentsPageState extends State<LabourPaymentsPage> {
  late Future<List<Map<String, dynamic>>> _paymentsFuture;
  late Future<Map<String, int>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = LabourTransactionService.fetchTransactions();
    _summaryFuture = LabourTransactionService.fetchMonthlySummary();
  }

  @override
  Widget build(BuildContext context) {
    return LabourLayout(
      title: 'My Payments',
      currentIndex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== SUMMARY =====
          FutureBuilder<Map<String, int>>(
            future: _summaryFuture,
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              final s = snap.data!;
              return Row(
                children: [
                  _summaryCard('Salary', s['salary']!, Colors.green),
                  _summaryCard('Advance', s['advance']!, Colors.orange),
                  _summaryCard('Balance', s['balance']!, Colors.blue),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          /// ===== TRANSACTION LIST (ONLY SCROLLABLE PART) =====
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _paymentsFuture,
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.data!.isEmpty) {
                  return const Center(child: Text('No payments found'));
                }

                return ListView.separated(
                  itemCount: snap.data!.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _paymentTile(context, snap.data![i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _summaryCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                '₹ $value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(BuildContext context, Map<String, dynamic> p) {
    final isAdvance = p['payment_type'] == 'ADVANCE';
    final date =
        DateFormat('dd MMM yyyy').format(DateTime.parse(p['created_at']));
    final paidBy = p['paid_by'];

    return ListTile(
      leading: Icon(
        isAdvance ? Icons.payments : Icons.account_balance_wallet,
        color: isAdvance ? Colors.orange : Colors.green,
      ),
      title: Text(
        '₹ ${p['amount']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${p['payment_type']} • $date\nBy ${paidBy['name']} (${paidBy['role']})',
      ),
      isThreeLine: true,
      onTap: () => _showDetails(context, p),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹ ${p['amount']}'),
            Text('Type: ${p['payment_type']}'),
            Text(
              'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(p['created_at']))}',
            ),
            Text('Paid By: ${p['paid_by']['name']}'),
            if (p['note'] != null && p['note'].toString().isNotEmpty)
              Text('Note: ${p['note']}'),
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
}
