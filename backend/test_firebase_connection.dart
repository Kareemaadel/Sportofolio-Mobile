import 'dart:io';
import 'package:dotenv/dotenv.dart';

void main() async {
  print('🔍 Testing Firebase Connection...\n');
  
  // Load environment variables
  try {
    var env = DotEnv(includePlatformEnvironment: true)..load();
    print('✅ .env file loaded successfully');
    
    // Check required environment variables
    print('\n📋 Checking Environment Variables:');
    final requiredVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_SERVICE_ACCOUNT_PATH',
      'FIREBASE_DATABASE_URL',
      'FIREBASE_STORAGE_BUCKET',
    ];
    
    bool allVarsPresent = true;
    for (var varName in requiredVars) {
      final value = env[varName];
      if (value != null && value.isNotEmpty && !value.contains('your-')) {
        print('   ✅ $varName: ${value.substring(0, value.length > 30 ? 30 : value.length)}...');
      } else {
        print('   ❌ $varName: Missing or placeholder!');
        allVarsPresent = false;
      }
    }
    
    if (!allVarsPresent) {
      print('\n❌ Some environment variables are missing or contain placeholders!');
      print('   Please update your .env file with correct values.');
      exit(1);
    }
    
    // Check if service account file exists
    print('\n📄 Checking Service Account File:');
    final serviceAccountPath = env['FIREBASE_SERVICE_ACCOUNT_PATH'] ?? './firebase-service-account.json';
    final file = File(serviceAccountPath);
    
    if (await file.exists()) {
      print('   ✅ Service account file exists: $serviceAccountPath');
      
      // Check if it's valid JSON
      try {
        final content = await file.readAsString();
        if (content.contains('"project_id"') && content.contains('"private_key"')) {
          print('   ✅ Service account file appears to be valid');
        } else {
          print('   ⚠️  Service account file might be invalid');
        }
      } catch (e) {
        print('   ❌ Error reading service account file: $e');
      }
    } else {
      print('   ❌ Service account file NOT found: $serviceAccountPath');
      print('   Please download it from Firebase Console:');
      print('   Firebase Console → Settings → Service accounts → Generate new private key');
      exit(1);
    }
    
    // Check uploads directory
    print('\n📁 Checking Uploads Directory:');
    final uploadsPath = env['UPLOAD_PATH'] ?? './uploads';
    final uploadsDir = Directory(uploadsPath);
    
    if (await uploadsDir.exists()) {
      print('   ✅ Uploads directory exists: $uploadsPath');
    } else {
      print('   ⚠️  Uploads directory not found: $uploadsPath');
      print('   Creating it now...');
      await uploadsDir.create(recursive: true);
      print('   ✅ Uploads directory created');
    }
    
    print('\n' + '=' * 60);
    print('✅ BASIC CONFIGURATION CHECK PASSED!');
    print('=' * 60);
    print('\n📝 Next Steps:');
    print('   1. Make sure you have the Firebase Admin SDK package installed');
    print('   2. Run your backend server: dart run bin/server.dart');
    print('   3. The server will attempt to connect to Firebase on startup');
    print('\n💡 To test actual Firebase connection, you need to:');
    print('   - Add firebase_admin or cloud_firestore package to pubspec.yaml');
    print('   - Initialize Firebase in your server code');
    print('   - Try a simple read/write operation');
    
  } catch (e) {
    print('❌ Error loading .env file: $e');
    print('\nMake sure:');
    print('   1. The .env file exists in the backend directory');
    print('   2. You have the dotenv package installed');
    print('   3. Run: dart pub get');
    exit(1);
  }
}
