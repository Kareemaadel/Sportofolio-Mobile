import 'package:cloud_firestore/cloud_firestore.dart';

/// Migration script to add followers and following fields to existing users
/// Run this once to update all existing user documents
class UserMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrate all existing users to add followers and following fields
  Future<void> migrateUsersAddFollowersFollowing() async {
    try {
      print('Starting migration: Adding followers and following fields...');

      // Get all users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      int totalUsers = usersSnapshot.docs.length;
      int updatedUsers = 0;
      int skippedUsers = 0;

      print('Found $totalUsers user(s) to process');

      // Process each user
      for (var doc in usersSnapshot.docs) {
        try {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

          // Check if fields already exist
          bool needsUpdate = false;
          Map<String, dynamic> updates = {};

          if (!userData.containsKey('followers')) {
            updates['followers'] = 0;
            needsUpdate = true;
          }

          if (!userData.containsKey('following')) {
            updates['following'] = 0;
            needsUpdate = true;
          }

          if (needsUpdate) {
            await _firestore.collection('users').doc(doc.id).update(updates);
            updatedUsers++;
            print('✓ Updated user: ${userData['email'] ?? doc.id}');
          } else {
            skippedUsers++;
            print(
              '- Skipped user (already has fields): ${userData['email'] ?? doc.id}',
            );
          }
        } catch (e) {
          print('✗ Error updating user ${doc.id}: $e');
        }
      }

      print('\n=== Migration Complete ===');
      print('Total users: $totalUsers');
      print('Updated: $updatedUsers');
      print('Skipped: $skippedUsers');
      print('========================\n');
    } catch (e) {
      print('Migration failed: $e');
      rethrow;
    }
  }
}
