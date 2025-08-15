import 'package:flutter/material.dart';
import '../api.dart';

class HomePage extends StatefulWidget {
  final String token;
  final VoidCallback onLogout;
  const HomePage({super.key, required this.token, required this.onLogout});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController tc;
  final api = Api();

  final areas = const ['Palasia','Vijay Nagar','Rajwada','Indrapuri','Bhawarkuan','Sudama Nagar'];
  String area = 'Palasia';
  final Map<String, List<double>> areaCoords = const {
    'Palasia':[22.7196,75.8577],
    'Vijay Nagar':[22.7536,75.8937],
    'Rajwada':[22.7177,75.8555],
    'Indrapuri':[22.7601,75.8814],
    'Bhawarkuan':[22.6907,75.8656],
    'Sudama Nagar':[22.6703,75.8277],
  };

  final smsText = TextEditingController();
  final urlText = TextEditingController();
  final phoneText = TextEditingController(text: '+919876543210');

  bool busy = false;
  String? last;

  @override
  void initState() {
    super.initState();
    tc = TabController(length: 3, vsync: this);
  }

  Future<void> submit(String type) async {
    setState(() { busy = true; last = null; });
    final coords = areaCoords[area] ?? [22.7196,75.8577];
    final payload = type == 'sms'
        ? {'text': smsText.text}
        : type == 'url'
        ? {'url': urlText.text}
        : {'phone': phoneText.text};

    try {
      final data = await api.createReport(
        token: widget.token,
        type: type,
        payload: payload,
        lat: coords[0],
        lon: coords[1],
        area: area,
      );
      setState(() => last = 'OK: ${data['id']} (${data['type']})');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => last = 'ERR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Suspicious Activity'),
        bottom: TabBar(controller: tc, tabs: const [ Tab(text: 'SMS'), Tab(text: 'URL'), Tab(text: 'VOIP') ]),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: area,
              items: areas.map((a)=>DropdownMenuItem(value:a, child: Text(a))).toList(),
              onChanged: (v)=> setState(()=> area = v!),
            ),
          ),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: widget.onLogout),
        ],
      ),
      body: TabBarView(controller: tc, children: [
        // SMS
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(controller: smsText, maxLines: 5, decoration: const InputDecoration(
                labelText: 'SMS text', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: busy ? null : () => submit('sms'),
                child: Text(busy ? 'Submitting...' : 'Submit SMS Report')),
            if (last != null) Padding(padding: const EdgeInsets.only(top:8), child: Text(last!)),
          ]),
        ),
        // URL
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(controller: urlText, decoration: const InputDecoration(
                labelText: 'URL', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: busy ? null : () => submit('url'),
                child: Text(busy ? 'Submitting...' : 'Submit URL Report')),
            if (last != null) Padding(padding: const EdgeInsets.only(top:8), child: Text(last!)),
          ]),
        ),
        // VOIP
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(controller: phoneText, decoration: const InputDecoration(
                labelText: 'Phone number (+91...)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: busy ? null : () => submit('voip'),
                child: Text(busy ? 'Submitting...' : 'Submit VOIP Report')),
            if (last != null) Padding(padding: const EdgeInsets.only(top:8), child: Text(last!)),
          ]),
        ),
      ]),
    );
  }
}
