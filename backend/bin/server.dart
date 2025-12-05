import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

import '../lib/src/routes/api_routes.dart';
import '../lib/src/middleware/error_middleware.dart';
import '../lib/src/middleware/logger_middleware.dart';
import '../lib/src/config/database.dart';

final _logger = Logger('Server');

void main() async {
  // Initialize logger
  _setupLogging();

  // Load environment variables
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Get configuration from environment
  final port = int.parse(env['PORT'] ?? '8080');
  final host = env['HOST'] ?? 'localhost';

  // Initialize database
  try {
    await FirebaseConfig.initialize();
    _logger.info('Firebase initialized successfully');
  } catch (e) {
    _logger.severe('Failed to initialize Firebase: $e');
    _logger.warning('Server will continue but Firebase features may not work');
  }

  // Create router
  final router = Router();

  // Add API routes
  router.mount('/api/', ApiRoutes().router);

  // Health check endpoint
  router.get('/health', (Request request) {
    return Response.ok('Server is running');
  });

  // Configure middleware
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(loggerMiddleware())
      .addMiddleware(errorMiddleware())
      .addHandler(router);

  // Start server
  final server = await shelf_io.serve(
    handler,
    host,
    port,
  );

  _logger.info('Server listening on http://${server.address.host}:${server.port}');
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
