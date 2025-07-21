import 'package:flutter/material.dart';

import 'apis/auth_api.dart';

import 'presentation/screens/login_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _mail = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await AuthApi.register(_mail.text.trim(), _pass.text);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Register')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _mail,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(labelText: 'Password (min 6)'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _register,
                child: const Text('Create account'),
              ),
          ],
        ),
      ),
    ),
  );
}
