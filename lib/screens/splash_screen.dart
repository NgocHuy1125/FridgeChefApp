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
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenAndRedirect();
    });
  }

  void _listenAndRedirect() {
    if (!mounted) return;

    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        if (!mounted) return;
        final Session? session = data.session;
        _navigate(session);
      },
      onError: (error) {
        if (mounted) {
          print('Auth state stream error: $error');

          _navigate(null);
        }
      },
    );

    _navigate(supabase.auth.currentSession);
  }

  // Hàm điều hướng tập trung
  void _navigate(Session? session) {
    if (!mounted) return;

    if (session == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreenWrapper()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
