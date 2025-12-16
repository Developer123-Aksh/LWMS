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
                      value: _selectedSite,
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