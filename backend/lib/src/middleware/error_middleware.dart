import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ErrorMiddleware');

Middleware errorMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e, stackTrace) {
        _logger.severe('Error handling request: $e', e, stackTrace);

        if (e is AppException) {
          return Response(
            e.statusCode,
            body: e.toJson(),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.internalServerError(
          body: '{"error": "Internal server error"}',
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}

class AppException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? data;

  AppException(this.message, {this.statusCode = 400, this.data});

  String toJson() {
    final json = {
      'error': message,
      if (data != null) 'data': data,
    };
    return json.toString();
  }
}
