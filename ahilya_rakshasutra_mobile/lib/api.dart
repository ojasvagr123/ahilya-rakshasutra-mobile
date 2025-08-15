import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

const _OVERRIDE = String.fromEnvironment('API_BASE', defaultValue: '');
String getApiBase() {
  if (_OVERRIDE.isNotEmpty) return _OVERRIDE;
  // Web uses localhost; Android emulator uses 10.0.2.2
  return kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
}

class Api {
  final String base = getApiBase();

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final resp = await http.post(
      Uri.parse('$base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    if (resp.statusCode != 200) {
      throw 'Login failed (${resp.statusCode}): ${resp.body}';
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createReport({
    required String token,
    required String type, // 'sms' | 'url' | 'voip'
    required Map<String, dynamic> payload,
    required double lat,
    required double lon,
    required String area,
  }) async {
    final resp = await http.post(
      Uri.parse('$base/reports'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': type,
        'payload': payload,
        'lat': lat,
        'lon': lon,
        'area': area,
      }),
    );
    if (resp.statusCode != 200) {
      throw 'Report failed (${resp.statusCode}): ${resp.body}';
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
