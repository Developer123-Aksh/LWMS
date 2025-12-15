import 'package:flutter/material.dart';
import 'manager_layout.dart';

class ManagerPaymentsPage extends StatefulWidget {
  const ManagerPaymentsPage({super.key});

  @override
  State<ManagerPaymentsPage> createState() => _ManagerPaymentsPageState();
}

class _ManagerPaymentsPageState extends State<ManagerPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLabour;
  String? _paymentType;
  String? _paymentMethod;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'Payments',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Payment Summary
            _buildPaymentSummary(context),
            const SizedBox(height: 24),

            // Make Payment Form
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
                            'Make Payment',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Labour Selection
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Labour',
                          prefixIcon: Icon(Icons.person),
                          helperText: 'Choose labour to make payment',
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
                          helperText: 'Enter payment amount',
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
                          DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                          DropdownMenuItem(value: 'Bonus', child: Text('Bonus')),
                          DropdownMenuItem(value: 'Overtime', child: Text('Overtime')),
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

                      // Payment Method
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          prefixIcon: Icon(Icons.payment),
                          helperText: 'How will you pay?',
                        ),
                        value: _paymentMethod,
                        items: const [
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                          DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                          DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select payment method';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: Icon(Icons.note),
                          helperText: 'Add any additional information',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _processPayment,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Process Payment'),
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
                    '₹ 18,000',
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
                    '12 transactions',
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
            color: Colors.blue.withOpacity(0.1),
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
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'This Month',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '₹ 3,20,000',
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
                    '↑ 12% from last month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
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
            itemCount: 8,
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
                subtitle: Text('${_getPaymentType(index)} • ${_getPaymentMethod(index)}'),
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

  List<DropdownMenuItem<String>> _getLabourList() {
    final labours = [
      'Ram Kumar',
      'Vijay Singh',
      'Suresh Patel',
      'Prakash Sharma',
      'Anil Desai',
      'Rajesh Mehta',
      'Ganesh Rao',
      'Mukesh Joshi'
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
              Text('Payment Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReceiptRow('Labour', _selectedLabour ?? ''),
              const Divider(),
              _buildReceiptRow('Amount', '₹ ${_amountController.text}'),
              const Divider(),
              _buildReceiptRow('Type', _paymentType ?? ''),
              const Divider(),
              _buildReceiptRow('Method', _paymentMethod ?? ''),
              const Divider(),
              _buildReceiptRow('Date', DateTime.now().toString().split(' ')[0]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Receipt'),
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
      _paymentMethod = null;
      _amountController.clear();
      _notesController.clear();
    });
  }

  Color _getPaymentColor(int index) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }

  String _getPaymentLabour(int index) {
    final names = ['Ram Kumar', 'Vijay Singh', 'Suresh Patel', 'Prakash Sharma'];
    return names[index % names.length];
  }

  String _getPaymentType(int index) {
    final types = ['Salary', 'Advance', 'Bonus', 'Overtime'];
    return types[index % types.length];
  }

  String _getPaymentMethod(int index) {
    final methods = ['Cash', 'UPI', 'Bank Transfer', 'Cheque'];
    return methods[index % methods.length];
  }

  String _getPaymentAmount(int index) {
    final amounts = ['₹ 2,500', '₹ 1,500', '₹ 3,000', '₹ 1,800'];
    return amounts[index % amounts.length];
  }

  String _getPaymentTime(int index) {
    final times = ['Just now', '1 hour ago', '2 hours ago', '3 hours ago'];
    return times[index % times.length];
  }
}