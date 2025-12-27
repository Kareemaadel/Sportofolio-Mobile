import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../lib/services/migrate_users.dart';

/// Run this script to migrate existing users
/// Usage: flutter run -t scripts/run_migration.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Initializing Firebase...');
  await Firebase.initializeApp();
  print('Firebase initialized successfully\n');

  // Run migration
  final migration = UserMigration();
  await migration.migrateUsersAddFollowersFollowing();

  print('Migration script completed. You can now close this.');
}
