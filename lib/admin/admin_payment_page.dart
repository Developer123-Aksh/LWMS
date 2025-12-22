import 'package:flutter/material.dart';
import 'admin_layout.dart';
import '../services/profile_service.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  String _roleFilter = 'ALL';
  String? _venueId;

  late Future<List<Map<String, dynamic>>> _venuesFuture;
  Future<List<Map<String, dynamic>>>? _teamFuture;

  @override
  void initState() {
    super.initState();
    _venuesFuture = AdminTransactionsService.fetchSites();
  }

  void _loadTeam() {
    if (_venueId == null) return;

    _teamFuture = AdminPaymentService.fetchTeam(
      venueId: _venueId!,
      role: _roleFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Payments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== SITE (MANDATORY) =====
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _venuesFuture,
            builder: (_, s) {
              if (!s.hasData) {
                return const CircularProgressIndicator();
              }

              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Site',
                  border: OutlineInputBorder(),
                ),
                value: _venueId,
                items: s.data!
                    .map(
                      (v) => DropdownMenuItem<String>(
                        value: v['id'],
                        child: Text(v['name']),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _venueId = v;
                    _roleFilter = 'ALL';
                    _loadTeam();
                  });
                },
              );
            },
          ),

          const SizedBox(height: 16),

          /// ===== ROLE FILTER =====
          if (_venueId != null)
            Wrap(
              spacing: 8,
              children: [
                _filter('ALL'),
                _filter('MANAGER'),
                _filter('SUPERVISOR'),
                _filter('LABOUR'),
              ],
            ),

          const SizedBox(height: 12),

          /// ===== LIST =====
          if (_venueId == null)
            const Expanded(
              child: Center(
                child: Text('Please select a site to continue'),
              ),
            )
          else
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _teamFuture,
                builder: (_, s) {
                  if (!s.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (s.data!.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return ListView.separated(
                    itemCount: s.data!.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final u = s.data![i];
                      return ListTile(
                        title: Text(u['name']),
                        subtitle: Text(u['role']),
                        trailing:
                            const Icon(Icons.payments_outlined),
                        onTap: () => _openPaymentDialog(u),
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

  Widget _filter(String role) {
    return ChoiceChip(
      label: Text(role),
      selected: _roleFilter == role,
      onSelected: (_) {
        setState(() {
          _roleFilter = role;
          _loadTeam();
        });
      },
    );
  }

  /// ===============================
  /// PAYMENT DIALOG
  /// ===============================
  void _openPaymentDialog(Map<String, dynamic> user) {
    final int salary = user['salary'] ?? 0;
    int dueAdvance = user['due_advance'] ?? 0;

    String paymentType = 'SALARY';
    bool clearAdvance = false;

    final TextEditingController amountCtrl =
        TextEditingController(text: salary.toString());

    void recalc() {
      if (paymentType == 'SALARY') {
        amountCtrl.text = clearAdvance
            ? (salary - dueAdvance).clamp(0, salary).toString()
            : salary.toString();
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setD) {
            return AlertDialog(
              title: Text('Pay ${user['name']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _row('Salary', salary),
                  _row('Due Advance', dueAdvance),

                  const Divider(),

                  DropdownButtonFormField<String>(
                    value: paymentType,
                    decoration:
                        const InputDecoration(labelText: 'Payment Type'),
                    items: const [
                      DropdownMenuItem(
                          value: 'SALARY', child: Text('Salary')),
                      DropdownMenuItem(
                          value: 'ADVANCE', child: Text('Advance')),
                    ],
                    onChanged: (v) {
                      setD(() {
                        paymentType = v!;
                        clearAdvance = false;
                        amountCtrl.text =
                            paymentType == 'SALARY'
                                ? salary.toString()
                                : '';
                      });
                    },
                  ),

                  if (paymentType == 'SALARY' && dueAdvance > 0)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: clearAdvance,
                      title: const Text('Clear Due Advance'),
                      onChanged: (v) {
                        setD(() {
                          clearAdvance = v!;
                          recalc();
                        });
                      },
                    ),

                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pay Amount',
                      prefixText: '₹ ',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  child: const Text('Pay'),
                  onPressed: () async {
                    final amount =
                        int.tryParse(amountCtrl.text) ?? 0;
                    if (amount <= 0) return;
                    await AdminPaymentService.makePayment(
                      venueId: _venueId!, // ✅ CRITICAL FIX
                      paidTo: user['id'],
                      amount: amount,
                      paymentType: paymentType,
                      updatedDueAdvance: true,
                    );

                    if (mounted) Navigator.pop(context);
                    setState(() => _loadTeam());
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _row(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text('₹ $value',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
