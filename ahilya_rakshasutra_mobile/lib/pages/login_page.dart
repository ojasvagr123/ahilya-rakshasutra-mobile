import 'package:flutter/material.dart';
import '../api.dart';

class LoginPage extends StatefulWidget {
  final void Function(String token) onAuthed;
  const LoginPage({super.key, required this.onAuthed});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController(text: '+911111111111'); // normal user
  final pass = TextEditingController(text: 'pass');
  bool busy = false;
  String? err;
  final api = Api();

  Future<void> _login() async {
    setState(() { busy = true; err = null; });
    try {
      final data = await api.login(phone.text.trim(), pass.text);
      final token = data['token']['access_token'] as String;
      widget.onAuthed(token);
    } catch (e) {
      setState(() => err = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone (+91...)')),
          const SizedBox(height: 8),
          TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: busy ? null : _login, child: Text(busy ? 'Signing in...' : 'Sign in')),
          if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: Colors.red)))
        ]),
      ),
    );
  }
}
