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
    return AuthApi.verify();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _future,
    builder: (c, snap) {
      if (!snap.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return snap.data == true ? const HomePage() : const LoginScreen();
    },
  );
}
