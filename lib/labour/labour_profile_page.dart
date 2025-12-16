import 'package:flutter/material.dart';
import 'labour_layout.dart';
import '../services/profile_service.dart';

class LabourProfilePage extends StatefulWidget {
  const LabourProfilePage({super.key});

  @override
  State<LabourProfilePage> createState() => _LabourProfilePageState();
}

class _LabourProfilePageState extends State<LabourProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = LabourService.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return LabourLayout(
      title: 'My Profile',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found'));
          }

          final data = snapshot.data!;

          final name = data['name'] ?? '-';
          final role = data['role'] ?? '-';
          final status = data['status'] ?? '-';
          final mobile = data['mobile_no'] ?? '-';
          final aadhar = data['aadhar_no'] ?? '-';
          final orgName = data['org_name'] ?? '-';
          final venueName = data['venue_name'] ?? 'Not Assigned';
          final venueAddress = data['venue_address'] ?? '';
          final joinedDate = data['created_at'] != null
              ? _formatDate(DateTime.parse(data['created_at']))
              : '-';

          return SingleChildScrollView(
            child: Column(
              children: [
                // ================= HEADER =================
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'ACTIVE'
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status == 'ACTIVE'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================= WORK INFO =================
                _section(context, 'Work Information', [
                  _row(
                    Icons.location_city,
                    'Assigned Site',
                    venueAddress.isNotEmpty
                        ? '$venueName, $venueAddress'
                        : venueName,
                  ),
                  _row(Icons.calendar_today, 'Joined Date', joinedDate),
                ]),

                const SizedBox(height: 16),

                // ================= PERSONAL INFO =================
                _section(context, 'Personal Information', [
                  _row(Icons.business, 'Organisation', orgName),
                  _row(Icons.phone, 'Mobile', mobile),
                  _row(Icons.credit_card, 'Aadhaar Number', aadhar),
                ]),

                const SizedBox(height: 16),

                // ================= SETTINGS =================
                _section(context, 'Settings', [
                  ListTile(
                    leading: Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Change Password'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HELPERS =================

  Widget _section(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
