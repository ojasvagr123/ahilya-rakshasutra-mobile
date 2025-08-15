import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahilya RakshaSutra',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0B1220)),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? token;
  bool loading = true;

  @override
  void initState() { super.initState(); _loadToken(); }

  Future<void> _loadToken() async {
    final sp = await SharedPreferences.getInstance();
    setState(() { token = sp.getString('token'); loading = false; });
  }

  Future<void> _onAuthed(String t) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', t);
    setState(() => token = t);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return token == null
        ? LoginPage(onAuthed: _onAuthed)
        : HomePage(token: token!, onLogout: () {
      SharedPreferences.getInstance().then((sp) async {
        await sp.remove('token');
        setState(() => token = null);
      });
    });
  }
}
