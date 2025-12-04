import 'package:firedart/firedart.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';
import '../config/database.dart';
import '../models/user.dart' as models;

class AuthService {
  static String? _jwtSecret;

  static String get jwtSecret {
    if (_jwtSecret == null) {
      var env = DotEnv(includePlatformEnvironment: true)..load();
      _jwtSecret = env['JWT_SECRET'] ?? 'default_secret_key';
    }
    return _jwtSecret!;
  }

  /// Register a new user with Firebase Auth and Firestore
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Check if user already exists in Firestore
      final existingUsers = await FirebaseConfig.db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingUsers.isNotEmpty) {
        throw Exception('User with this email already exists');
      }

      // Sign up with Firebase Auth
      final userCredential = await FirebaseConfig.auth.signUp(email, password);
      final userId = userCredential.user.id;

      // Hash password for additional security
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      // Create user document in Firestore
      final userData = {
        'id': userId,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseConfig.db.collection('users').document(userId).set(userData);

      // Generate tokens
      final token = _generateToken(userId, email);
      final refreshToken = _generateRefreshToken(userId);

      return {
        'token': token,
        'refreshToken': refreshToken,
        'user': {
          'id': userId,
          'email': email,
          'name': name,
        }
      };
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login user with Firebase Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      await FirebaseConfig.auth.signIn(email, password);
      
      // Get user data from Firestore
      final usersQuery = await FirebaseConfig.db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (usersQuery.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = usersQuery.first;
      final userId = userDoc['id'] as String;
      final userName = userDoc['name'] as String;

      // Generate tokens
      final token = _generateToken(userId, email);
      final refreshToken = _generateRefreshToken(userId);

      return {
        'token': token,
        'refreshToken': refreshToken,
        'user': {
          'id': userId,
          'email': email,
          'name': userName,
        }
      };
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Refresh access token
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final jwt = JWT.verify(refreshToken, SecretKey(jwtSecret));
      final userId = jwt.payload['userId'] as String;

      // Get user data from Firestore
      final userDoc = await FirebaseConfig.db
          .collection('users')
          .document(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final email = userDoc['email'] as String;

      final newToken = _generateToken(userId, email);
      final newRefreshToken = _generateRefreshToken(userId);

      return {
        'token': newToken,
        'refreshToken': newRefreshToken,
      };
    } catch (e) {
      throw Exception('Invalid refresh token: ${e.toString()}');
    }
  }

  /// Verify Firebase ID token
  static Future<Map<String, dynamic>?> verifyFirebaseToken(String idToken) async {
    try {
      // In a production environment, you would verify the token with Firebase Admin SDK
      // For now, we'll verify our custom JWT
      return verifyToken(idToken);
    } catch (e) {
      return null;
    }
  }

  /// Generate custom JWT token
  static String _generateToken(String userId, String email) {
    final jwt = JWT({
      'userId': userId,
      'email': email,
      'iat': DateTime.now().millisecondsSinceEpoch,
    });

    return jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: const Duration(hours: 24),
    );
  }

  /// Generate refresh token
  static String _generateRefreshToken(String userId) {
    final jwt = JWT({
      'userId': userId,
      'type': 'refresh',
      'iat': DateTime.now().millisecondsSinceEpoch,
    });

    return jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: const Duration(days: 30),
    );
  }

  /// Verify custom JWT token
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      await FirebaseConfig.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Get current user from Firebase Auth
  static Future<models.User?> getCurrentUser() async {
    try {
      final currentUser = FirebaseConfig.auth.user;
      if (currentUser == null) return null;

      final userDoc = await FirebaseConfig.db
          .collection('users')
          .document(currentUser.id)
          .get();

      if (!userDoc.exists) return null;

      return models.User.fromJson(userDoc.map);
    } catch (e) {
      return null;
    }
  }
}
