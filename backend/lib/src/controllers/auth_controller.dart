import 'package:shelf/shelf.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class AuthController {
  static Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final email = data['email'] as String?;
      final password = data['password'] as String?;

      if (email == null || password == null) {
        return Response(400, body: '{"error": "Email and password are required"}');
      }

      final result = await AuthService.login(email, password);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(401, body: '{"error": "Invalid credentials"}');
    }
  }

  static Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final email = data['email'] as String?;
      final password = data['password'] as String?;
      final name = data['name'] as String?;

      if (email == null || password == null || name == null) {
        return Response(400, body: '{"error": "Name, email and password are required"}');
      }

      final result = await AuthService.register(name, email, password);

      return Response(201,
        body: jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: '{"error": "Registration failed: $e"}');
    }
  }

  static Future<Response> refreshToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final refreshToken = data['refreshToken'] as String?;

      if (refreshToken == null) {
        return Response(400, body: '{"error": "Refresh token is required"}');
      }

      final result = await AuthService.refreshToken(refreshToken);

      return Response.ok(
        jsonEncode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(401, body: '{"error": "Invalid refresh token"}');
    }
  }
}
