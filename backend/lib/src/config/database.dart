import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:firedart/firedart.dart';
import 'package:logging/logging.dart';

final _logger = Logger('FirebaseConfig');

class FirebaseConfig {
  static late Firestore firestore;
  static late FirebaseAuth auth;
  static String? projectId;
  static String? serviceAccountPath;
  
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      _logger.info('Firebase already initialized');
      return;
    }

    try {
      var env = DotEnv(includePlatformEnvironment: true)..load();

      projectId = env['FIREBASE_PROJECT_ID'];
      serviceAccountPath = env['FIREBASE_SERVICE_ACCOUNT_PATH'];

      if (projectId == null || projectId!.isEmpty) {
        throw Exception('FIREBASE_PROJECT_ID not set in environment variables');
      }

      // Initialize Firedart (for server-side Firestore access)
      _logger.info('Initializing Firebase with project: $projectId');

      // For server-side, we use service account authentication
      if (serviceAccountPath != null && File(serviceAccountPath!).existsSync()) {
        // Using service account
        _logger.info('Using service account from: $serviceAccountPath');
        
        // Initialize Firestore
        Firestore.initialize(projectId!);
        firestore = Firestore.instance;

        // Initialize Auth
        FirebaseAuth.initialize(
          env['FIREBASE_API_KEY'] ?? '',
          VolatileStore(),
        );
        auth = FirebaseAuth.instance;

        _initialized = true;
        _logger.info('Firebase initialized successfully');
      } else {
        _logger.warning(
          'Service account file not found at: $serviceAccountPath',
        );
        _logger.warning(
          'Firebase will work with limited functionality. Add service account key for full features.',
        );

        // Initialize with basic setup
        Firestore.initialize(projectId!);
        firestore = Firestore.instance;
        
        _initialized = true;
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize Firebase', e, stackTrace);
      rethrow;
    }
  }

  /// Get Firestore instance
  static Firestore get db {
    if (!_initialized) {
      throw Exception('Firebase not initialized. Call FirebaseConfig.initialize() first');
    }
    return firestore;
  }

  /// Get Auth instance
  static FirebaseAuth get authentication {
    if (!_initialized) {
      throw Exception('Firebase not initialized. Call FirebaseConfig.initialize() first');
    }
    return auth;
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;
}
