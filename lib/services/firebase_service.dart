import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream for real-time updates
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'username': '',
          'role': '',
          'bio': '',
          'profileImageUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
          'isActive': true,
        });

        // Send email verification
        await user.sendEmailVerification();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get user data stream for real-time updates
  Stream<DocumentSnapshot> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? bio,
    String? role,
    String? username,
    String? profileImageUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name.trim();
      if (bio != null) updates['bio'] = bio.trim();
      if (role != null) updates['role'] = role.trim();
      if (username != null) {
        // Check if username is unique before updating
        bool isAvailable = await checkUsernameAvailability(username, uid);
        if (!isAvailable) {
          throw 'Username is already taken';
        }
        updates['username'] = username.trim().toLowerCase();
      }
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw e.toString();
    }
  }

  // Check if username is available
  Future<bool> checkUsernameAvailability(String username, [String? currentUid]) async {
    try {
      final usernameDoc = await _firestore
          .collection('usernames')
          .doc(username.trim().toLowerCase())
          .get();

      if (!usernameDoc.exists) {
        return true; // Username is available
      }

      // If current user is checking their own username, it's available
      if (currentUid != null && usernameDoc.data()?['uid'] == currentUid) {
        return true;
      }

      return false; // Username is taken by someone else
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  // Reserve username (create username document)
  Future<void> reserveUsername(String username, String uid) async {
    try {
      await _firestore.collection('usernames').doc(username.trim().toLowerCase()).set({
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error reserving username: ${e.toString()}';
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      User? user = currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Get username and delete from usernames collection
        final userData = await getUserData(user.uid);
        if (userData != null && userData['username'] != null && userData['username'].isNotEmpty) {
          await _firestore
              .collection('usernames')
              .doc(userData['username'])
              .delete();
        }

        // Delete user from Firebase Auth
        await user.delete();
      }
    } catch (e) {
      throw 'Error deleting account: ${e.toString()}';
    }
  }

  // Re-authenticate user (needed for sensitive operations like delete account or change password)
  Future<void> reauthenticateUser(String email, String password) async {
    try {
      User? user = currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      User? user = currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      User? user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'An error occurred: ${e.message ?? 'Please try again'}';
    }
  }
}
