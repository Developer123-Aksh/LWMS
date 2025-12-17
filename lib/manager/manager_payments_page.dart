import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manager_layout.dart';

class ManagerPaymentsPage extends StatefulWidget {
  const ManagerPaymentsPage({super.key});

  @override
  State<ManagerPaymentsPage> createState() => _ManagerPaymentsPageState();
}

class _ManagerPaymentsPageState extends State<ManagerPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedLabourId;
  String? _paymentType;
  String? _paymentMethod;

  late Future<List<Map<String, dynamic>>> _laboursFuture;
  late Future<List<Map<String, dynamic>>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _laboursFuture = _fetchLabours();
    _recentFuture = _fetchRecentPayments();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ================= DATA =================

  Future<List<Map<String, dynamic>>> _fetchLabours() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final me = await client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    return await client
        .from('users')
        .select('id, name')
        .eq('organisation_id', me['organisation_id'])
        .eq('role', 'LABOUR')
        .eq('status', 'ACTIVE');
  }

  Future<List<Map<String, dynamic>>> _fetchRecentPayments() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;

    final me = await client
        .from('users')
        .select('organisation_id')
        .eq('id', uid)
        .single();

    return await client
        .from('transactions')
        .select('''
          id,
          amount,
          created_at,
          payment_type,
          paid_to:users!transactions_paid_to_fkey(name)
        ''')
        .eq('organisation_id', me['organisation_id'])
        .order('created_at', ascending: false)
        .limit(5);
  }

  // ================= INSERT PAYMENT =================

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final client = Supabase.instance.client;
    final user = client.auth.currentUser!;

    final me = await client
        .from('users')
        .select('organisation_id, venue_id')
        .eq('id', user.id)
        .single();

    await client.from('transactions').insert({
      'organisation_id': me['organisation_id'],
      'venue_id': me['venue_id'],
      'paid_by': user.id,
      'paid_to': _selectedLabourId,
      'amount': int.parse(_amountController.text),
      'payment_type': _paymentType,
      'note': _notesController.text.isEmpty ? null : _notesController.text,
      'status': 'ACTIVE',
    });

    _clearForm();
    setState(() {
      _recentFuture = _fetchRecentPayments();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded successfully')),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'Payments',
      child: SingleChildScrollView(
        child: Column(
          children: [
            _paymentForm(context),
            const SizedBox(height: 24),
            _recentPayments(context),
          ],
        ),
      ),
    );
  }

  Widget _paymentForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _laboursFuture,
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedLabourId,
                    items: snap.data!
                        .map((l) => DropdownMenuItem<String>(
                              value: l['id'] as String,
                              child: Text(l['name'] as String),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select Labour',
                    ),
                    onChanged: (v) => setState(() => _selectedLabourId = v),
                    validator: (v) =>
                        v == null ? 'Select a labour' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _paymentType,
                items: const [
                  DropdownMenuItem(value: 'SALARY', child: Text('Salary')),
                  DropdownMenuItem(value: 'ADVANCE', child: Text('Advance')),
                ],
                decoration:
                    const InputDecoration(labelText: 'Payment Type'),
                onChanged: (v) => setState(() => _paymentType = v),
                validator: (v) => v == null ? 'Select type' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processPayment,
                  child: const Text('Process Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentPayments(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _recentFuture,
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snap.data!.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final tx = snap.data![i];
              return ListTile(
                title: Text(tx['paid_to']['name']),
                trailing: Text('₹ ${tx['amount']}'),
                subtitle: Text(tx['payment_type']),
              );
            },
          ),
        );
      },
    );
  }

  void _clearForm() {
    setState(() {
      _selectedLabourId = null;
      _paymentType = null;
      _paymentMethod = null;
      _amountController.clear();
      _notesController.clear();
    });
  }
}
