import 'package:flutter/material.dart';
import 'package:fridge_chef_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/screens/signup_screen.dart';

// Wrapper để cung cấp AuthProvider cho màn hình Login
class LoginScreenWrapper extends StatelessWidget {
  const LoginScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const LoginScreen(),
    );
  }
}

// Giao diện chính của màn hình Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _onSignInPressed() async {
    if (!_formKey.currentState!.validate()) return;

    // context.read<T>() dùng để gọi hàm mà không lắng nghe sự thay đổi
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<T>() dùng để lắng nghe sự thay đổi và build lại UI
    final isLoading = context.watch<AuthProvider>().isLoading;
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (Phần logo và tiêu đề giữ nguyên) ...
                const Icon(
                  Icons.soup_kitchen_outlined,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chào mừng đến với Fridge Chef',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator:
                      (val) => val!.isEmpty ? 'Vui lòng nhập email' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator:
                      (val) =>
                          val!.length < 6
                              ? 'Mật khẩu phải có ít nhất 6 ký tự'
                              : null,
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _onSignInPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Đăng nhập'),
                    ),
                const SizedBox(height: 12),

                // Nút chuyển sang màn hình Đăng ký
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SignUpScreenWrapper(),
                      ),
                    );
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                ),

                // ... (Phần ngăn cách và các nút mạng xã hội giữ nguyên) ...
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('HOẶC'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed:
                          isLoading ? null : authProvider.signInWithGoogle,
                      icon: const Icon(
                        Icons.g_mobiledata,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed:
                          isLoading ? null : authProvider.signInWithFacebook,
                      icon: const Icon(
                        Icons.facebook,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
