import 'package:flutter/material.dart';
import 'admin_layout.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  String _selectedSite = 'All';
  String _selectedType = 'All';
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
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
                  title: 'Total Payout',
                  value: '₹ 6,80,000',
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Date Range Filter
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
                  
                  // Site Filter
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Site',
                        prefixIcon: Icon(Icons.location_city),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      // value: _selectedSite,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Sites')),
                        DropdownMenuItem(value: 'Site A', child: Text('Site A')),
                        DropdownMenuItem(value: 'Site B', child: Text('Site B')),
                        DropdownMenuItem(value: 'Site C', child: Text('Site C')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSite = value!;
                        });
                      },
                    ),
                  ),

                  // Type Filter
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Types')),
                        DropdownMenuItem(value: 'Labour Payment', child: Text('Labour Payment')),
                        DropdownMenuItem(value: 'Material', child: Text('Material')),
                        DropdownMenuItem(value: 'Equipment', child: Text('Equipment')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),

                  // Clear Filters
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedSite = 'All';
                        _selectedType = 'All';
                        _dateRange = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),

                  // Export Button
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
        width: 175,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
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
      title: Text(
        transaction['amount'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(transaction['description']),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.location_city,
                size: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                transaction['site'],
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            transaction['date'],
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          _buildTypeBadge(transaction['type']),
        ],
      ),
      onTap: () => _showTransactionDetails(context, transaction),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    switch (type) {
      case 'Labour Payment':
        color = Colors.green;
        break;
      case 'Material':
        color = Colors.blue;
        break;
      case 'Equipment':
        color = Colors.orange;
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
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getTransaction(int index) {
    final transactions = [
      {
        'amount': '₹ 2,500',
        'description': 'Daily wages - 5 labours',
        'site': 'Site A',
        'date': '15 Dec 2025',
        'type': 'Labour Payment',
        'icon': Icons.groups,
        'color': Colors.green,
        'paymentMethod': 'UPI',
        'transactionId': 'TXN00245',
      },
      {
        'amount': '₹ 15,000',
        'description': 'Cement bags - 100 units',
        'site': 'Site B',
        'date': '14 Dec 2025',
        'type': 'Material',
        'icon': Icons.inventory,
        'color': Colors.blue,
        'paymentMethod': 'Bank Transfer',
        'transactionId': 'TXN00244',
      },
      {
        'amount': '₹ 3,500',
        'description': 'JCB rental - Half day',
        'site': 'Site C',
        'date': '14 Dec 2025',
        'type': 'Equipment',
        'icon': Icons.construction,
        'color': Colors.orange,
        'paymentMethod': 'Cash',
        'transactionId': 'TXN00243',
      },
      {
        'amount': '₹ 1,800',
        'description': 'Daily wages - 3 labours',
        'site': 'Site A',
        'date': '13 Dec 2025',
        'type': 'Labour Payment',
        'icon': Icons.groups,
        'color': Colors.green,
        'paymentMethod': 'Cash',
        'transactionId': 'TXN00242',
      },
      {
        'amount': '₹ 25,000',
        'description': 'Steel rods - 500 kg',
        'site': 'Site D',
        'date': '12 Dec 2025',
        'type': 'Material',
        'icon': Icons.inventory,
        'color': Colors.blue,
        'paymentMethod': 'Bank Transfer',
        'transactionId': 'TXN00241',
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
              _buildDetailRow(Icons.payments, 'Amount', transaction['amount']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.description, 'Description', transaction['description']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.location_city, 'Site', transaction['site']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.calendar_today, 'Date', transaction['date']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.category, 'Type', transaction['type']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.payment, 'Payment Method', transaction['paymentMethod']),
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