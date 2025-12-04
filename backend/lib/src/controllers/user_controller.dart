import 'package:shelf/shelf.dart';
import 'dart:convert';

class UserController {
  static Future<Response> getAll(Request request) async {
    // TODO: Implement get all users logic
    final users = [
      {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
      {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
    ];

    return Response.ok(
      jsonEncode({'users': users}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<Response> getById(Request request, String id) async {
    // TODO: Implement get user by id logic
    final user = {'id': id, 'name': 'John Doe', 'email': 'john@example.com'};

    return Response.ok(
      jsonEncode(user),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<Response> create(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // TODO: Implement create user logic
      final user = {
        'id': '3',
        'name': data['name'],
        'email': data['email'],
      };

      return Response(201,
        body: jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: '{"error": "Invalid request data"}');
    }
  }

  static Future<Response> update(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // TODO: Implement update user logic
      final user = {
        'id': id,
        'name': data['name'] ?? 'Updated Name',
        'email': data['email'] ?? 'updated@example.com',
      };

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: '{"error": "Invalid request data"}');
    }
  }

  static Future<Response> delete(Request request, String id) async {
    // TODO: Implement delete user logic
    return Response.ok(
      jsonEncode({'message': 'User deleted successfully', 'id': id}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
