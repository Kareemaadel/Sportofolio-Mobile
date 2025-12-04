import 'package:shelf/shelf.dart';
import '../services/auth_service.dart';

/// Middleware to authenticate requests using JWT tokens
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Get token from Authorization header
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
          body: '{"error": "Missing or invalid authorization header"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Extract token
      final token = authHeader.substring(7); // Remove 'Bearer ' prefix

      // Verify token
      final payload = AuthService.verifyToken(token);

      if (payload == null) {
        return Response(401,
          body: '{"error": "Invalid or expired token"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Add user info to request context
      final updatedRequest = request.change(context: {
        'userId': payload['userId'],
        'email': payload['email'],
      });

      return await innerHandler(updatedRequest);
    };
  };
}

/// Helper function to get user ID from authenticated request
String? getUserIdFromRequest(Request request) {
  return request.context['userId'] as String?;
}

/// Helper function to get email from authenticated request
String? getEmailFromRequest(Request request) {
  return request.context['email'] as String?;
}
