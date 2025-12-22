import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_layout.dart';
import '../services/profile_service.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  DateTimeRange? _range;
  String _site = 'ALL';
  String _type = 'ALL';

  late Future<List<Map<String, dynamic>>> _txnsFuture;
  late Future<Map<String, dynamic>> _summaryFuture;
  late Future<List<Map<String, dynamic>>> _sitesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
    _sitesFuture = AdminTransactionsService.fetchSites();
  }

  void _reload() {
    _txnsFuture = AdminTransactionsService.fetchTransactions(
      range: _range,
      siteId: _site,
      type: _type,
    );
    _summaryFuture = AdminTransactionsService.fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Transactions',
      child: Column(
        children: [
          /// ===== SUMMARY =====
          FutureBuilder<Map<String, dynamic>>(
            future: _summaryFuture,
            builder: (_, s) {
              if (!s.hasData) return const SizedBox();
              return Row(
                children: [
                  _summary('Total Payout', '₹ ${s.data!['total_payout']}'),
                  _summary('Transactions', s.data!['count'].toString()),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          /// ===== FILTERS =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    child: Text(_range == null
                        ? 'Date Range'
                        : '${DateFormat('dd/MM').format(_range!.start)} - ${DateFormat('dd/MM').format(_range!.end)}'),
                    onPressed: () async {
                      final r = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (r != null) {
                        setState(() {
                          _range = r;
                          _reload();
                        });
                      }
                    },
                  ),

                  /// Site
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _sitesFuture,
                    builder: (_, s) {
                      if (!s.hasData) return const SizedBox();
                      return DropdownButton<String>(
                        value: _site,
                        items: [
                          const DropdownMenuItem(value: 'ALL', child: Text('All Sites')),
                          ...s.data!.map((v) => DropdownMenuItem(
                                value: v['id'],
                                child: Text(v['name']),
                              )),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _site = v!;
                            _reload();
                          });
                        },
                      );
                    },
                  ),

                  /// Type
                  DropdownButton<String>(
                    value: _type,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Types')),
                      DropdownMenuItem(value: 'ADVANCE', child: Text('Advance')),
                      DropdownMenuItem(value: 'SALARY', child: Text('Salary')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _type = v!;
                        _reload();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// ===== LIST =====
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _txnsFuture,
              builder: (_, s) {
                if (!s.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (s.data!.isEmpty) {
                  return const Center(child: Text('No transactions'));
                }

                return ListView.builder(
                  itemCount: s.data!.length,
                  itemBuilder: (_, i) {
                    final t = s.data![i];
                    return ListTile(
                      title: Text('₹ ${t['amount']} • ${t['payment_type']}'),
                      subtitle: Text(
                        '${t['paid_to']['name']} ← ${t['paid_by']['name']}',
                      ),
                      trailing: Text(
                        DateFormat('dd MMM').format(
                          DateTime.parse(t['created_at']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
