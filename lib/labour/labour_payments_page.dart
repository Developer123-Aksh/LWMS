import 'package:flutter/material.dart';
import 'labour_layout.dart';

class LabourPaymentsPage extends StatefulWidget {
  const LabourPaymentsPage({super.key});

  @override
  State<LabourPaymentsPage> createState() => _LabourPaymentsPageState();
}

class _LabourPaymentsPageState extends State<LabourPaymentsPage> {
  String _selectedFilter = 'All';
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return LabourLayout(
      title: 'My Payments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSummaryCard(
                  context,
                  title: 'Total Earned',
                  value: '₹ 18,000',
                  subtitle: 'This Month',
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  title: 'Advances',
                  value: '₹ 4,500',
                  subtitle: '3 payments',
                  icon: Icons.payments,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  title: 'Balance',
                  value: '₹ 13,500',
                  subtitle: 'To receive',
                  icon: Icons.savings,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Date Range
                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDateRange(context),
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _dateRange == null
                            ? 'Select Date Range'
                            : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),

                  // Type Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Types')),
                        DropdownMenuItem(value: 'Daily Wage', child: Text('Daily Wage')),
                        DropdownMenuItem(value: 'Advance', child: Text('Advance')),
                        DropdownMenuItem(value: 'Bonus', child: Text('Bonus')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),

                  // Clear Filters
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _dateRange = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment History
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Payment History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: 15,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _buildPaymentTile(context, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(BuildContext context, int index) {
    final payment = _getPayment(index);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: payment['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          payment['icon'],
          color: payment['color'],
          size: 24,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              payment['amount'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              _buildTypeBadge(payment['type']),
              const SizedBox(width: 8),
              Text('•'),
              const SizedBox(width: 8),
              Text(
                payment['paidBy'],
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            payment['date'],
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
      onTap: () => _showPaymentDetails(context, payment),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    switch (type) {
      case 'Daily Wage':
        color = Colors.green;
        break;
      case 'Advance':
        color = Colors.orange;
        break;
      case 'Bonus':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getPayment(int index) {
    final payments = [
      {
        'amount': '₹ 600',
        'type': 'Daily Wage',
        'paidBy': 'Supervisor',
        'date': '15 Dec 2025, 6:00 PM',
        'icon': Icons.payments,
        'color': Colors.green,
        'transactionId': 'TXN00${245 - index}',
        'paymentMethod': 'Cash',
        'notes': 'Full day work',
      },
      {
        'amount': '₹ 1,500',
        'type': 'Advance',
        'paidBy': 'Supervisor',
        'date': '14 Dec 2025, 2:30 PM',
        'icon': Icons.payments,
        'color': Colors.orange,
        'transactionId': 'TXN00${244 - index}',
        'paymentMethod': 'Cash',
        'notes': 'Emergency advance',
      },
      {
        'amount': '₹ 600',
        'type': 'Daily Wage',
        'paidBy': 'Manager',
        'date': '13 Dec 2025, 6:00 PM',
        'icon': Icons.payments,
        'color': Colors.green,
        'transactionId': 'TXN00${243 - index}',
        'paymentMethod': 'UPI',
        'notes': 'Full day work',
      },
      {
        'amount': '₹ 1,000',
        'type': 'Bonus',
        'paidBy': 'Manager',
        'date': '12 Dec 2025, 5:00 PM',
        'icon': Icons.payments,
        'color': Colors.blue,
        'transactionId': 'TXN00${242 - index}',
        'paymentMethod': 'Bank Transfer',
        'notes': 'Good performance',
      },
    ];
    return payments[index % payments.length];
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showPaymentDetails(BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.receipt, 'Transaction ID', payment['transactionId']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.payments, 'Amount', payment['amount']),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.category, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTypeBadge(payment['type']),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person, 'Paid By', payment['paidBy']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.payment, 'Method', payment['paymentMethod']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.calendar_today, 'Date & Time', payment['date']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.note, 'Notes', payment['notes']),
            ],
          ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}