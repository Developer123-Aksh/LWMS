import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'manager_layout.dart';

class ManagerProfilePage extends StatefulWidget {
  const ManagerProfilePage({super.key});

  @override
  State<ManagerProfilePage> createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ManagerService.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ManagerLayout(
      title: 'My Profile',
      child: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }

          final d = snap.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _header(context, d),
                _section(context, 'Personal Information', [
                  _row('Organisation', d['org_name']),
                  _row('Email', d['email_id']),
                  _row('Mobile', d['mobile_no']),
                  _row('Aadhaar', d['aadhar_no'] ?? '-'),
                ]),
                _section(context, 'Work Details', [
                  _row('Site', d['venue_name'] ?? 'Not Assigned'),
                  _row('Status', d['status']),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext c, Map d) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 12),
              Text(d['name'], style: Theme.of(c).textTheme.titleLarge),
              Text(d['role']),
            ],
          ),
        ),
      );

  Widget _section(BuildContext c, String t, List<Widget> ch) => Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(t, style: Theme.of(c).textTheme.titleMedium),
            ),
            ...ch,
          ],
        ),
      );

  Widget _row(String l, String v) => ListTile(title: Text(l), subtitle: Text(v));
}
