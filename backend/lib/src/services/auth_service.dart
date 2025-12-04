import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dotenv/dotenv.dart';

class AuthService {
  static String? _jwtSecret;

  static String get jwtSecret {
    if (_jwtSecret == null) {
      var env = DotEnv(includePlatformEnvironment: true)..load();
      _jwtSecret = env['JWT_SECRET'] ?? 'default_secret_key';
    }
    return _jwtSecret!;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    // TODO: Implement actual database lookup
    // This is a placeholder implementation
    
    // Example: Verify user exists and password matches
    // final user = await UserRepository.findByEmail(email);
    // if (user == null) throw Exception('User not found');
    
    // final isValidPassword = BCrypt.checkpw(password, user.passwordHash);
    // if (!isValidPassword) throw Exception('Invalid password');

    // For now, using mock data
    final mockPasswordHash = BCrypt.hashpw('password123', BCrypt.gensalt());
    
    if (!BCrypt.checkpw(password, mockPasswordHash) && password != 'password123') {
      throw Exception('Invalid credentials');
    }

    final userId = '1'; // Mock user ID
    final token = _generateToken(userId, email);
    final refreshToken = _generateRefreshToken(userId);

    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': {
        'id': userId,
        'email': email,
        'name': 'John Doe',
      }
    };
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    // TODO: Implement actual database insert
    // Check if user already exists
    // final existingUser = await UserRepository.findByEmail(email);
    // if (existingUser != null) throw Exception('User already exists');

    // Hash password
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    // Save user to database
    // final user = await UserRepository.create({
    //   'name': name,
    //   'email': email,
    //   'passwordHash': passwordHash,
    // });

    final userId = '2'; // Mock user ID
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
  }

  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final jwt = JWT.verify(refreshToken, SecretKey(jwtSecret));
      final userId = jwt.payload['userId'] as String;
      final email = jwt.payload['email'] as String;

      final newToken = _generateToken(userId, email);
      final newRefreshToken = _generateRefreshToken(userId);

      return {
        'token': newToken,
        'refreshToken': newRefreshToken,
      };
    } catch (e) {
      throw Exception('Invalid refresh token');
    }
  }

  static String _generateToken(String userId, String email) {
    final jwt = JWT({
      'userId': userId,
      'email': email,
      'iat': DateTime.now().millisecondsSinceEpoch,
    });

    return jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: Duration(hours: 24),
    );
  }

  static String _generateRefreshToken(String userId) {
    final jwt = JWT({
      'userId': userId,
      'type': 'refresh',
      'iat': DateTime.now().millisecondsSinceEpoch,
    });

    return jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: Duration(days: 30),
    );
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
