import 'package:firedart/firedart.dart';
import '../config/database.dart';
import '../models/user.dart';

void main() async {
  // Initialize Firebase before using Firestore
  await FirebaseConfig.initialize();

  // Create a test user
  try {
    var newUser = await UserService.createUser({
      'name': 'Test User',
      'email': 'testuser@example.com',
      'passwordHash': 'hashedpassword123',
    });
    print('Created user:');
    print(newUser);
  } catch (e) {
    print('Error creating user: $e');
  }

  // List all users
  try {
    var users = await UserService.getAllUsers();
    print('User count: ${users.length}');
    for (var user in users) {
      print(user);
    }
  } catch (e) {
    print('Error: $e');
  }
}

class UserService {
  static final _usersCollection = 'users';

  /// Get all users from Firestore
  static Future<List<User>> getAllUsers() async {
    try {
      final snapshot =
          await FirebaseConfig.db.collection(_usersCollection).get();

      return snapshot.map((doc) {
        return User.fromJson(doc.map);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  /// Get user by ID
  static Future<User?> getUserById(String userId) async {
    try {
      final doc = await FirebaseConfig.db
          .collection(_usersCollection)
          .document(userId)
          .get();

      if (doc.map.isEmpty) {
        return null;
      }

      return User.fromJson(doc.map);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Get user by email
  static Future<User?> getUserByEmail(String email) async {
    try {
      final snapshot = await FirebaseConfig.db
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.isEmpty) {
        return null;
      }

      return User.fromJson(snapshot.first.map);
    } catch (e) {
      throw Exception('Failed to get user by email: ${e.toString()}');
    }
  }

  /// Create new user
  static Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final userId = userData['id'] as String? ?? _generateUserId();

      final newUser = {
        'id': userId,
        'name': userData['name'] as String,
        'email': userData['email'] as String,
        'passwordHash': userData['passwordHash'] as String,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseConfig.db
          .collection(_usersCollection)
          .document(userId)
          .set(newUser);

      return User.fromJson(newUser);
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  /// Update user
  static Future<User> updateUser(
      String userId, Map<String, dynamic> updates) async {
    try {
      // Get existing user
      final existingDoc = await FirebaseConfig.db
          .collection(_usersCollection)
          .document(userId)
          .get();

      if (existingDoc.map.isEmpty) {
        throw Exception('User not found');
      }

      // Prepare updated data
      final updatedData = {
        ...existingDoc.map,
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Remove fields that shouldn't be updated
      updatedData.remove('id');
      updatedData.remove('createdAt');
      updatedData.remove('passwordHash'); // Use separate method for password

      await FirebaseConfig.db
          .collection(_usersCollection)
          .document(userId)
          .update(updatedData);

      return User.fromJson(updatedData);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  /// Delete user
  static Future<void> deleteUser(String userId) async {
    try {
      await FirebaseConfig.db
          .collection(_usersCollection)
          .document(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  /// Update user password hash
  static Future<void> updatePassword(
      String userId, String newPasswordHash) async {
    try {
      await FirebaseConfig.db
          .collection(_usersCollection)
          .document(userId)
          .update({
        'passwordHash': newPasswordHash,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  /// Search users by name
  static Future<List<User>> searchUsersByName(String searchTerm) async {
    try {
      final snapshot =
          await FirebaseConfig.db.collection(_usersCollection).get();

      return snapshot
          .where((doc) {
            final name = doc['name'] as String;
            return name.toLowerCase().contains(searchTerm.toLowerCase());
          })
          .map((doc) => User.fromJson(doc.map))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }

  /// Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      final snapshot = await FirebaseConfig.db
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .get();

      return snapshot.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email: ${e.toString()}');
    }
  }

  /// Generate unique user ID
  static String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
