import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

/// Standalone migration script to add followers and following fields to existing users
/// Run with: dart run lib/migrate_existing_users.dart
void main() async {
  print('=== User Migration Script ===\n');

  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully\n');

    final firestore = FirebaseFirestore.instance;

    print('Starting migration: Adding followers and following fields...');

    // Get all users
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();

    int totalUsers = usersSnapshot.docs.length;
    int updatedUsers = 0;
    int skippedUsers = 0;

    print('Found $totalUsers user(s) to process\n');

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
          await firestore.collection('users').doc(doc.id).update(updates);
          updatedUsers++;
          print(
            '✓ Updated user: ${userData['email'] ?? userData['name'] ?? doc.id}',
          );
        } else {
          skippedUsers++;
          print(
            '- Skipped user (already has fields): ${userData['email'] ?? userData['name'] ?? doc.id}',
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
    print('✗ Migration failed: $e');
  }
}
