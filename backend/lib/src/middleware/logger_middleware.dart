import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Request');

Middleware loggerMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final startTime = DateTime.now();
      final response = await innerHandler(request);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logger.info(
        '${request.method} ${request.url} - ${response.statusCode} - ${duration.inMilliseconds}ms',
      );

      return response;
    };
  };
}
