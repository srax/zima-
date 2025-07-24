import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/apis/auth_api.dart';
import 'home/presentation/home_page.dart';
import 'auth/presentation/screens/login_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<bool> _future;

  @override
  void initState() {
    super.initState();
    _future = _checkAuth();
  }

  Future<bool> _checkAuth() async {
    final pref = await SharedPreferences.getInstance();
    final saved = pref.getString('jwt');
    AuthApi.setToken(saved);
    try {
      return await AuthApi.verify();
    } catch (_) {
      // Any exception (network, unauthenticated, etc.) should result in navigating
      // to the login page rather than leaving the app stuck on the loader.
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _future,
    builder: (c, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final isAuthed = snap.data ?? false;
      return isAuthed ? const HomePage() : const LoginScreen();
    },
  );
}
