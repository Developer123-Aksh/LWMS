import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'supervisor_layout.dart';

class SupervisorTransactionsPage extends StatefulWidget {
  const SupervisorTransactionsPage({super.key});

  @override
  State<SupervisorTransactionsPage> createState() =>
      _SupervisorTransactionsPageState();
}

class _SupervisorTransactionsPageState
    extends State<SupervisorTransactionsPage> {
  String _typeFilter = 'All';
  DateTimeRange? _dateRange;

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = SupervisorService.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return SupervisorLayout(
      title: 'Transactions',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final all = snapshot.data!;
          final filtered = _applyFilters(all);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow(all),
              const SizedBox(height: 24),
              _filters(context),
              const SizedBox(height: 16),
              Expanded(child: _transactionsList(filtered)),
            ],
          );
        },
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryRow(List<Map<String, dynamic>> data) {
    final total = data.fold<num>(
      0,
      (sum, e) => sum + (e['amount'] ?? 0),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _summaryCard(
            'Total Paid',
            '₹ ${total.toStringAsFixed(0)}',
            Icons.payments,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _summaryCard(
            'Transactions',
            data.length.toString(),
            Icons.receipt_long,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: SizedBox(
        width: 180,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FILTERS =================

  Widget _filters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                _dateRange == null
                    ? 'Select Date'
                    : '${_dateRange!.start.day}/${_dateRange!.start.month}'
                      ' - ${_dateRange!.end.day}/${_dateRange!.end.month}',
              ),
              onPressed: () => _selectDateRange(context),
            ),
            DropdownButton<String>(
              value: _typeFilter,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Types')),
                DropdownMenuItem(value: 'ADVANCE', child: Text('Advance')),
                DropdownMenuItem(value: 'DAILY', child: Text('Daily Wage')),
              ],
              onChanged: (v) => setState(() => _typeFilter = v!),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
              onPressed: () {
                setState(() {
                  _typeFilter = 'All';
                  _dateRange = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= LIST =================

  Widget _transactionsList(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }

    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: data.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _transactionTile(data[i]),
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> t) {
    return ListTile(
      leading: const Icon(Icons.payments),
      title: Text(
        t['paid_to']?['name'] ?? '-',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        '₹ ${t['amount']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${t['payment_type']}'),
          Text('Status: ${t['status']}'),
          Text(
            t['created_at'].toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      onTap: () => _showDetails(context, t),
    );
  }

  // ================= DETAILS =================

  void _showDetails(BuildContext context, Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Paid To', t['paid_to']?['name']),
            _row('Amount', '₹ ${t['amount']}'),
            _row('Type', t['payment_type']),
            _row('Status', t['status']),
            _row('Note', t['note'] ?? '-'),
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

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: ${value ?? '-'}'),
    );
  }

  // ================= HELPERS =================

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> data) {
    return data.where((e) {
      if (_typeFilter != 'All' &&
          e['payment_type'] != _typeFilter) return false;

      if (_dateRange != null) {
        final d = DateTime.parse(e['created_at']);
        if (d.isBefore(_dateRange!.start) ||
            d.isAfter(_dateRange!.end)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
}
