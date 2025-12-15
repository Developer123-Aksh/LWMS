// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../services/user_service.dart';
// import '../admin/admin_home.dart';
// import '../manager/manager_home.dart';
// import '../supervisor/supervisor_home.dart';
// import '../labour/labour_home.dart';
// import 'login_page.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<AuthState>(
//       stream: Supabase.instance.client.auth.onAuthStateChange,
//       builder: (context, snapshot) {
//         final session = snapshot.data?.session;

//         if (session == null) {
//           return const LoginPage();
//         }

//         return FutureBuilder(
//           future: UserService.fetchProfile(),
//           builder: (context, AsyncSnapshot snapshot) {
//             if (!snapshot.hasData) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }

//             final role = snapshot.data['role'];

//             switch (role) {
//               case 'ADMIN':
//                 return const AdminHome();
//               case 'MANAGER':
//                 return const ManagerHome();
//               case 'SUPERVISOR':
//                 return const SupervisorHome();
//               case 'LABOUR':
//                 return const LabourHome();
//               default:
//                 return const Scaffold(
//                   body: Center(child: Text('Invalid role')),
//                 );
//             }
//           },
//         );
//       },
//     );
//   }
// }
