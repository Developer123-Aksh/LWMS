import 'package:flutter/material.dart';
import 'supervisor_layout.dart';

class SupervisorPaymentsPage extends StatefulWidget {
  const SupervisorPaymentsPage({super.key});

  @override
  State<SupervisorPaymentsPage> createState() => _SupervisorPaymentsPageState();
}

class _SupervisorPaymentsPageState extends State<SupervisorPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLabour;
  String? _paymentType;
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SupervisorLayout(
      title: 'Payments',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Summary
            _buildPaymentSummary(context),
            const SizedBox(height: 24),

            // Pay Advance Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Pay Advance',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quick advance payment for labours in your team',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Labour Selection
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Labour',
                          prefixIcon: Icon(Icons.person),
                          helperText: 'Choose labour from your team',
                        ),
                        value: _selectedLabour,
                        items: _getLabourList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLabour = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a labour';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: Icon(Icons.currency_rupee),
                          helperText: 'Enter advance amount',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Payment Type
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Payment Type',
                          prefixIcon: Icon(Icons.category),
                          helperText: 'Select payment category',
                        ),
                        value: _paymentType,
                        items: const [
                          DropdownMenuItem(value: 'Advance', child: Text('Advance')),
                          DropdownMenuItem(value: 'Daily Wage', child: Text('Daily Wage')),
                          DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _paymentType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select payment type';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Reason
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          prefixIcon: Icon(Icons.note),
                          helperText: 'Enter reason for advance',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _processPayment,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirm Payment'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Payments
            _buildRecentPayments(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.payments,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '₹ 9,500',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Paid',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '8 payments',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: Colors.orange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '5',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pending Approvals',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Need manager approval',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPayments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPaymentColor(index).withOpacity(0.1),
                  child: Icon(
                    Icons.payments,
                    color: _getPaymentColor(index),
                  ),
                ),
                title: Text(_getPaymentLabour(index)),
                subtitle: Row(
                  children: [
                    Text(_getPaymentType(index)),
                    const Text(' • '),
                    _buildStatusBadge(_getPaymentStatus(index)),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getPaymentAmount(index),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _getPaymentTime(index),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Approved' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getLabourList() {
    final labours = [
      'Ram Kumar',
      'Vijay Singh',
      'Suresh Patel',
      'Prakash Sharma',
      'Anil Desai',
      'Rajesh Mehta',
    ];
    return labours.map((name) {
      return DropdownMenuItem(
        value: name,
        child: Text(name),
      );
    }).toList();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Payment Submitted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment request submitted successfully and pending manager approval.'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildReceiptRow('Labour', _selectedLabour ?? ''),
              const Divider(),
              _buildReceiptRow('Amount', '₹ ${_amountController.text}'),
              const Divider(),
              _buildReceiptRow('Type', _paymentType ?? ''),
              const Divider(),
              _buildReceiptRow('Status', 'Pending Approval'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedLabour = null;
      _paymentType = null;
      _amountController.clear();
      _reasonController.clear();
    });
  }

  Color _getPaymentColor(int index) {
    final colors = [Colors.green, Colors.blue, Colors.orange];
    return colors[index % colors.length];
  }

  String _getPaymentLabour(int index) {
    final names = ['Ram Kumar', 'Vijay Singh', 'Suresh Patel', 'Prakash Sharma'];
    return names[index % names.length];
  }

  String _getPaymentType(int index) {
    final types = ['Advance', 'Daily Wage', 'Emergency'];
    return types[index % types.length];
  }

  String _getPaymentStatus(int index) {
    return index % 3 == 0 ? 'Pending' : 'Approved';
  }

  String _getPaymentAmount(int index) {
    final amounts = ['₹ 1,200', '₹ 800', '₹ 1,500', '₹ 600'];
    return amounts[index % amounts.length];
  }

  String _getPaymentTime(int index) {
    final times = ['Just now', '1 hour ago', '2 hours ago', '3 hours ago'];
    return times[index % times.length];
  }
}