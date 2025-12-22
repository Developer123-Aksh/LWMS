import 'package:flutter/material.dart';
import 'manager_layout.dart';
import '../services/profile_service.dart';

class ManagerPaymentsPage extends StatefulWidget {
  const ManagerPaymentsPage({super.key});

  @override
  State<ManagerPaymentsPage> createState() => _ManagerPaymentsPageState();
}

class _ManagerPaymentsPageState extends State<ManagerPaymentsPage> {
  String _roleFilter = 'ALL';
  late Future<List<Map<String, dynamic>>> _teamFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _teamFuture = ManagerPaymentService.fetchTeam(role: _roleFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'Payments',
      child: Column(
        children: [
          /// ===== FILTER =====
          Row(
            children: [
              DropdownButton<String>(
                value: _roleFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All')),
                  DropdownMenuItem(
                      value: 'SUPERVISOR', child: Text('Supervisor')),
                  DropdownMenuItem(value: 'LABOUR', child: Text('Labour')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  _roleFilter = v;
                  _load();
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ===== TEAM LIST =====
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _teamFuture,
              builder: (_, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!s.hasData || s.data!.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.separated(
                  itemCount: s.data!.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final u = s.data![i];
                    final dueAdvance = (u['due_advance'] as int?) ?? 0;

                    return ListTile(
                      title: Text(u['name']),
                      subtitle: Text(u['role']),
                      trailing: Text(
                        'Due: ₹ $dueAdvance',
                        style: const TextStyle(color: Colors.red),
                      ),
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

  /// ===============================
  /// PAYMENT DIALOG
  /// ===============================
  void _openPaymentDialog(Map<String, dynamic> user) {
    final amountCtrl = TextEditingController();
    String type = 'ADVANCE';
    bool clearAdvance = false;

    final salary = (user['salary'] as int?) ?? 0;
    final dueAdvance = (user['due_advance'] as int?) ?? 0;
    final remainingSalary = (user['remaining_salary'] as int?) ?? 0;


    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final payable = remainingSalary;

          return AlertDialog(
            title: Text('Pay ${user['name']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Salary: ₹ $salary'),
                Text('Due Advance: ₹ $dueAdvance'),
                const SizedBox(height: 12),

                DropdownButton<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(
                        value: 'ADVANCE', child: Text('Advance')),
                    DropdownMenuItem(
                        value: 'SALARY', child: Text('Salary')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      type = v;
                      clearAdvance = false;
                      amountCtrl.clear();
                    });
                  },
                ),

                if (type == 'SALARY')
                  CheckboxListTile(
                    value: clearAdvance,
                    title: const Text('Clear Advance'),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        clearAdvance = v;
                        amountCtrl.text =
                        clearAdvance ? payable.toString() : '';
                      });
                    },
                  ),

                TextField(
                  controller: amountCtrl,
                  readOnly: type == 'SALARY' && clearAdvance,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: 'Amount'),
                ),

                if (type == 'SALARY' && clearAdvance)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '₹ $salary − ₹ $dueAdvance = ₹ $payable',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                onPressed: () async {
                  if (amountCtrl.text.isEmpty) return;

                  try {
                    debugPrint('DBG: Calling makePayment');

                    await ManagerPaymentService.makePayment(
                      paidTo: user['id'],
                      amount: int.parse(amountCtrl.text),
                      paymentType: type,
                      clearAdvance: clearAdvance,
                    );

                    debugPrint('DBG: Payment successful');

                    if (context.mounted) {
                      Navigator.pop(context);
                      _load();
                    }
                  } catch (e, st) {
                    debugPrint('❌ Payment failed: $e');
                    debugPrintStack(stackTrace: st);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Pay'),
              ),
            ],
          );
        },
      ),
    );
  }
}
