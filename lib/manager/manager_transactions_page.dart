import 'package:flutter/material.dart';
import 'manager_layout.dart';

class ManagerTransactionsPage extends StatefulWidget {
  const ManagerTransactionsPage({super.key});

  @override
  State<ManagerTransactionsPage> createState() => _ManagerTransactionsPageState();
}

class _ManagerTransactionsPageState extends State<ManagerTransactionsPage> {
  String _selectedFilter = 'All';
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'Transactions',
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
                  title: 'Total Paid',
                  value: '₹ 3,20,000',
                  subtitle: 'This Month',
                  icon: Icons.payments,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  title: 'Transactions',
                  value: '245',
                  subtitle: 'This Month',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  title: 'Today',
                  value: '₹ 18,000',
                  subtitle: '12 payments',
                  icon: Icons.today,
                  color: Colors.orange,
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
                        DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                        DropdownMenuItem(value: 'Advance', child: Text('Advance')),
                        DropdownMenuItem(value: 'Bonus', child: Text('Bonus')),
                        DropdownMenuItem(value: 'Overtime', child: Text('Overtime')),
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

                  // Export
                  ElevatedButton.icon(
                    onPressed: () => _showExportDialog(context),
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Transactions List
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Transaction History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: 20,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _buildTransactionTile(context, index);
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

  Widget _buildTransactionTile(BuildContext context, int index) {
    final transaction = _getTransaction(index);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: transaction['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          transaction['icon'],
          color: transaction['color'],
          size: 24,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              transaction['labour'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            transaction['amount'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
              _buildTypeBadge(transaction['type']),
              const SizedBox(width: 8),
              Text('•'),
              const SizedBox(width: 8),
              Icon(
                Icons.payment,
                size: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                transaction['method'],
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            transaction['date'],
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
      onTap: () => _showTransactionDetails(context, transaction),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    switch (type) {
      case 'Salary':
        color = Colors.green;
        break;
      case 'Advance':
        color = Colors.blue;
        break;
      case 'Bonus':
        color = Colors.orange;
        break;
      case 'Overtime':
        color = Colors.purple;
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

  Map<String, dynamic> _getTransaction(int index) {
    final transactions = [
      {
        'labour': 'Ram Kumar',
        'amount': '₹ 2,500',
        'type': 'Salary',
        'method': 'Cash',
        'date': '15 Dec 2025, 10:30 AM',
        'icon': Icons.payments,
        'color': Colors.green,
        'transactionId': 'TXN00${245 - index}',
        'notes': 'Monthly salary payment',
      },
      {
        'labour': 'Vijay Singh',
        'amount': '₹ 1,500',
        'type': 'Advance',
        'method': 'UPI',
        'date': '15 Dec 2025, 9:15 AM',
        'icon': Icons.payments,
        'color': Colors.blue,
        'transactionId': 'TXN00${244 - index}',
        'notes': 'Advance for emergency',
      },
      {
        'labour': 'Suresh Patel',
        'amount': '₹ 3,000',
        'type': 'Bonus',
        'method': 'Bank Transfer',
        'date': '14 Dec 2025, 4:20 PM',
        'icon': Icons.payments,
        'color': Colors.orange,
        'transactionId': 'TXN00${243 - index}',
        'notes': 'Performance bonus',
      },
      {
        'labour': 'Prakash Sharma',
        'amount': '₹ 1,800',
        'type': 'Overtime',
        'method': 'Cash',
        'date': '14 Dec 2025, 2:30 PM',
        'icon': Icons.payments,
        'color': Colors.purple,
        'transactionId': 'TXN00${242 - index}',
        'notes': 'Extra hours payment',
      },
      {
        'labour': 'Anil Desai',
        'amount': '₹ 2,200',
        'type': 'Salary',
        'method': 'UPI',
        'date': '13 Dec 2025, 11:45 AM',
        'icon': Icons.payments,
        'color': Colors.green,
        'transactionId': 'TXN00${241 - index}',
        'notes': 'Regular payment',
      },
    ];
    return transactions[index % transactions.length];
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

  void _showTransactionDetails(BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.receipt, 'Transaction ID', transaction['transactionId']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person, 'Labour', transaction['labour']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.payments, 'Amount', transaction['amount']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.category, 'Type', transaction['type']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.payment, 'Method', transaction['method']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.calendar_today, 'Date & Time', transaction['date']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.note, 'Notes', transaction['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Download receipt
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Receipt'),
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                // Export as PDF
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                // Export as Excel
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                // Export as CSV
              },
            ),
          ],
        ),
      ),
    );
  }
}