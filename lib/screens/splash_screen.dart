import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fridge_chef_app/main.dart';
import 'package:fridge_chef_app/screens/home_screen.dart';
import 'package:fridge_chef_app/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Tạo một biến để theo dõi StreamSubscription
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        final Session? session = data.session;
        _redirect(session);
      },
      onError: (error) {
        print('Auth state stream error: $error');
      },
    );

    _redirect(supabase.auth.currentSession);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _redirect(Session? session) {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      if (session != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreenWrapper(),
          ), // Dùng Wrapper
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
