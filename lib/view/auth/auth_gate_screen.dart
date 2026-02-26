import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zyiarah/view/home/home_screen.dart';
import 'package:zyiarah/view/worker/worker_dashboard_screen.dart';
import 'package:zyiarah/view/admin/admin_dashboard.dart';

import 'package:zyiarah/core/theme/app_colors.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool _loading = true;
  Widget _targetScreen = const HomeScreen(); // default to client

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    try {
      final userRecord = await Supabase.instance.client.from('users').select('role').eq('id', user.id).maybeSingle();
      if (userRecord != null && userRecord['role'] != null) {
        final role = userRecord['role'];
        if (role == 'admin') {
          _targetScreen = const AdminDashboardScreen();
        } else if (role == 'worker') {
          _targetScreen = const WorkerDashboardScreen();
        }
      }
    } catch (e) {
      debugPrint('Error getting user role in AuthGate: $e');
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return _targetScreen;
  }
}
