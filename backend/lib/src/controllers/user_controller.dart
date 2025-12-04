import 'package:shelf/shelf.dart';
import 'dart:convert';
import '../services/user_service.dart';

class UserController {
  /// Get all users
  static Future<Response> getAll(Request request) async {
    try {
      final users = await UserService.getAllUsers();

      final usersList = users.map((user) => user.toJson()).toList();

      return Response.ok(
        jsonEncode({'users': usersList}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch users: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Get user by ID
  static Future<Response> getById(Request request, String id) async {
    try {
      final user = await UserService.getUserById(id);

      if (user == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch user: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Create new user
  static Future<Response> create(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Validate required fields
      if (data['name'] == null || data['email'] == null) {
        return Response(400,
          body: jsonEncode({'error': 'Name and email are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if email already exists
      final emailExists = await UserService.emailExists(data['email'] as String);
      if (emailExists) {
        return Response(400,
          body: jsonEncode({'error': 'Email already in use'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = await UserService.createUser(data);

      return Response(201,
        body: jsonEncode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(400,
        body: jsonEncode({'error': 'Failed to create user: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Update user
  static Future<Response> update(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Remove sensitive fields that shouldn't be updated directly
      data.remove('id');
      data.remove('passwordHash');
      data.remove('createdAt');

      final user = await UserService.updateUser(id, data);

      return Response.ok(
        jsonEncode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      if (e.toString().contains('not found')) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response(400,
        body: jsonEncode({'error': 'Failed to update user: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Delete user
  static Future<Response> delete(Request request, String id) async {
    try {
      // Check if user exists
      final user = await UserService.getUserById(id);
      if (user == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await UserService.deleteUser(id);

      return Response.ok(
        jsonEncode({'message': 'User deleted successfully', 'id': id}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete user: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Search users by name
  static Future<Response> search(Request request) async {
    try {
      final searchTerm = request.url.queryParameters['q'];

      if (searchTerm == null || searchTerm.isEmpty) {
        return Response(400,
          body: jsonEncode({'error': 'Search term (q) is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final users = await UserService.searchUsersByName(searchTerm);
      final usersList = users.map((user) => user.toJson()).toList();

      return Response.ok(
        jsonEncode({'users': usersList, 'count': usersList.length}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Search failed: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
