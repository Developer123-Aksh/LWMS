import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'labour_layout.dart';
import '../services/profile_service.dart';

class LabourPaymentsPage extends StatefulWidget {
  const LabourPaymentsPage({super.key});

  @override
  State<LabourPaymentsPage> createState() => _LabourPaymentsPageState();
}

class _LabourPaymentsPageState extends State<LabourPaymentsPage> {
  String _selectedFilter = 'All';
  DateTimeRange? _dateRange;
  
  bool _isLoadingSummary = true;
  bool _isLoadingPayments = true;
  
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _allPayments = [];
  List<Map<String, dynamic>> _filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadSummary(),
      _loadPayments(),
    ]);
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoadingSummary = true);
    try {
      final summary = await LabourService.fetchPaymentSummary();
      setState(() {
        _summary = summary;
        _isLoadingSummary = false;
      });
    } catch (e) {
      setState(() => _isLoadingSummary = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading summary: $e')),
        );
      }
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoadingPayments = true);
    try {
      final payments = await LabourService.fetchPayments();
      setState(() {
        _allPayments = payments;
        _filteredPayments = payments;
        _isLoadingPayments = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => _isLoadingPayments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredPayments = _allPayments.where((payment) {
        // Filter by payment type
        if (_selectedFilter != 'All') {
          final type = (payment['payment_type'] as String).toUpperCase();
          final filter = _selectedFilter.toUpperCase().replaceAll(' ', '_');
          if (type != filter) return false;
        }

        // Filter by date range
        if (_dateRange != null) {
          final createdAt = DateTime.parse(payment['created_at']);
          if (createdAt.isBefore(_dateRange!.start) ||
              createdAt.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LabourLayout(
      title: 'My Payments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== SUMMARY (horizontal, non-expanding) =====
          SizedBox(
            height: 160,
            child: _isLoadingSummary
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSummaryCard(
                        context,
                        title: 'Total Earned',
                        value: '₹ ${_summary?['total_earned'] ?? 0}',
                        subtitle: 'This Month',
                        icon: Icons.account_balance_wallet,
                        color: Colors.blue,
                      ),
                      _buildSummaryCard(
                        context,
                        title: 'Advances',
                        value: '₹ ${_summary?['total_advances'] ?? 0}',
                        subtitle: '${_summary?['advance_count'] ?? 0} payments',
                        icon: Icons.payments,
                        color: Colors.orange,
                      ),
                      _buildSummaryCard(
                        context,
                        title: 'Balance',
                        value: '₹ ${_summary?['balance'] ?? 0}',
                        subtitle: 'To receive',
                        icon: Icons.savings,
                        color: Colors.green,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // ===== FILTERS (fixed height content) =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _dateRange == null
                          ? 'Select Date Range'
                          : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Daily Wage', child: Text('Daily Wage')),
                      DropdownMenuItem(value: 'Advance', child: Text('Advance')),
                      DropdownMenuItem(value: 'Bonus', child: Text('Bonus')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedFilter = v!);
                      _applyFilters();
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _dateRange = null;
                      });
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== PAYMENT LIST (ONLY SCROLLABLE AREA) =====
          Expanded(
            child: Card(
              child: _isLoadingPayments
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPayments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No payments found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: _filteredPayments.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final payment = _filteredPayments[index];
                              return _buildPaymentTile(context, payment);
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(title),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTile(BuildContext context, Map<String, dynamic> payment) {
    final paymentType = payment['payment_type'] as String;
    final amount = payment['amount'] as num;
    final createdAt = DateTime.parse(payment['created_at']);
    final paidBy = payment['paid_by'] as Map<String, dynamic>?;
    
    IconData icon;
    Color color;
    
    switch (paymentType.toUpperCase()) {
      case 'ADVANCE':
        icon = Icons.payments;
        color = Colors.orange;
        break;
      case 'BONUS':
        icon = Icons.card_giftcard;
        color = Colors.purple;
        break;
      case 'DAILY_WAGE':
      default:
        icon = Icons.account_balance_wallet;
        color = Colors.green;
        break;
    }

    final formattedDate = DateFormat('dd MMM yyyy').format(createdAt);
    final typeDisplay = paymentType.replaceAll('_', ' ').toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        '₹ ${amount.toStringAsFixed(0)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('$typeDisplay • $formattedDate'),
      trailing: paidBy != null
          ? Text(
              'By: ${paidBy['name']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
          : null,
      onTap: () => _showPaymentDetails(context, payment),
    );
  }

  // ================= ACTIONS =================
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _applyFilters();
    }
  }

  void _showPaymentDetails(BuildContext context, Map<String, dynamic> payment) {
    final paymentType = payment['payment_type'] as String;
    final amount = payment['amount'] as num;
    final createdAt = DateTime.parse(payment['created_at']);
    final note = payment['note'] as String?;
    final paidBy = payment['paid_by'] as Map<String, dynamic>?;
    
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
    final typeDisplay = paymentType.replaceAll('_', ' ').toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Amount', '₹ ${amount.toStringAsFixed(0)}'),
            _detailRow('Type', typeDisplay),
            _detailRow('Date', formattedDate),
            if (paidBy != null) _detailRow('Paid By', paidBy['name']),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(note),
            ],
          ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}