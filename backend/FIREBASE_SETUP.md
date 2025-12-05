# Firebase Setup Guide

## Part 1: Firebase Console Setup

### Step 1: Create Firebase Project

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click "Add project" or "Create a project"
   - Enter project name: `Sportofolio` (or your preferred name)
   - Click "Continue"

3. **Google Analytics (Optional)**
   - Enable or disable Google Analytics
   - If enabled, select your Analytics account
   - Click "Create project"
   - Wait for project creation to complete
   - Click "Continue"

---

### Step 2: Enable Firebase Authentication

1. **Navigate to Authentication**
   - In the left sidebar, click "Authentication"
   - Click "Get started"

2. **Enable Sign-in Methods**
   - Click on "Sign-in method" tab
   - Enable the following providers:

   **Email/Password:**
   - Click "Email/Password"
   - Toggle "Enable"
   - Click "Save"

   **Google (Optional):**
   - Click "Google"
   - Toggle "Enable"
   - Enter support email
   - Click "Save"

   **Other providers (Optional):**
   - Facebook, Twitter, Apple, etc.
   - Follow the same process

---

### Step 3: Create Firestore Database

1. **Navigate to Firestore Database**
   - In the left sidebar, click "Firestore Database"
   - Click "Create database"

2. **Choose Mode**
   - Select "Start in **production mode**" (we'll adjust rules later)
   - Click "Next"

3. **Select Location**
   - Choose a Cloud Firestore location closest to your users
   - Example: `us-central1`, `europe-west1`, etc.
   - Click "Enable"
   - Wait for database creation

4. **Set Security Rules (Important!)**
   - Click on "Rules" tab
   - Update rules for development:

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow authenticated users to read/write their own data
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Allow authenticated users to read all users (adjust as needed)
       match /users/{userId} {
         allow read: if request.auth != null;
       }
       
       // Add more collection rules as needed
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
   - Click "Publish"

---

### Step 4: Get Service Account Credentials

1. **Open Project Settings**
   - Click the gear icon (⚙️) next to "Project Overview"
   - Select "Project settings"

2. **Navigate to Service Accounts**
   - Click on "Service accounts" tab

3. **Generate Private Key**
   - Find "Firebase Admin SDK" section
   - Select "Node.js" or any language (we'll use the same format)
   - Click "Generate new private key"
   - Click "Generate key" in the confirmation dialog
   - A JSON file will be downloaded (e.g., `sportofolio-firebase-adminsdk-xxxxx.json`)

4. **Important: Keep This File Secure!**
   - ⚠️ This file contains sensitive credentials
   - Never commit it to version control
   - Store it securely in your backend folder

---

### Step 5: Get Project Configuration

1. **In Project Settings**
   - Under "General" tab
   - Scroll to "Your apps" section

2. **Copy Project Details**
   - **Project ID**: `your-project-id`
   - **Web API Key**: Found under "Your apps" → "Web apps"
   - **Storage Bucket**: `your-project-id.appspot.com`

---

### Step 6: Enable Required APIs (Optional but Recommended)

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Select your Firebase project

2. **Enable APIs**
   - Navigate to "APIs & Services" → "Library"
   - Search and enable:
     - ✅ Cloud Firestore API (should be auto-enabled)
     - ✅ Firebase Authentication API
     - ✅ Cloud Storage for Firebase (if using file uploads)

---

### Step 7: Set Up Firebase Storage (Optional)

If you need file uploads:

1. **Navigate to Storage**
   - In Firebase console, click "Storage"
   - Click "Get started"

2. **Set Security Rules**
   - Choose "Start in production mode"
   - Click "Next"

3. **Choose Location**
   - Select same location as Firestore
   - Click "Done"

4. **Update Storage Rules**
   - Click on "Rules" tab
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
   - Click "Publish"

---

## Part 2: Backend Project Setup

### Step 1: Move Service Account Key

1. **Move the downloaded JSON file**
   ```bash
   # Move the file to backend folder
   move Downloads\sportofolio-firebase-adminsdk-xxxxx.json backend\firebase-service-account.json
   ```

2. **Ensure it's in .gitignore**
   - Already added in `.gitignore`

---

### Step 2: Update Environment Variables

Update your `.env` file with Firebase credentials:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com

# Server Configuration
PORT=8080
HOST=localhost
ENVIRONMENT=development

# JWT Configuration (still needed for custom tokens)
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRATION=86400

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

---

### Step 3: Test Firebase Connection

Once the backend is updated (next steps), test the connection:

```bash
dart run bin/server.dart
```

Check logs for:
✅ "Firebase initialized successfully"

---

## Security Checklist

- [ ] Service account key file is NOT in version control
- [ ] Service account key file is in `.gitignore`
- [ ] Firestore security rules are configured
- [ ] Storage security rules are configured (if using)
- [ ] Environment variables are set correctly
- [ ] JWT_SECRET is strong and random
- [ ] Production Firestore rules are more restrictive

---

## Firestore Collections Structure (Recommended)

```
/users/{userId}
  - id: string
  - name: string
  - email: string
  - createdAt: timestamp
  - updatedAt: timestamp
  - profile: map (optional)

/sessions/{sessionId}
  - userId: string
  - token: string
  - createdAt: timestamp
  - expiresAt: timestamp

# Add Sportofolio specific collections
/athletes/{athleteId}
  - name, stats, etc...

/teams/{teamId}
  - name, members, etc...
```

---

## Testing Firebase

### Test Authentication:
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Verify in Firebase Console:
1. Go to Authentication → Users
2. You should see the newly created user

### Test Firestore:
```bash
curl http://localhost:8080/api/users
```

### Verify in Firebase Console:
1. Go to Firestore Database
2. You should see the `users` collection with data

---

## Useful Firebase Console URLs

- **Console Home**: https://console.firebase.google.com/
- **Authentication**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication
- **Firestore**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore
- **Storage**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/storage
- **Settings**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/general

---

## Troubleshooting

### "Permission denied" errors:
- Check Firestore security rules
- Ensure user is authenticated
- Verify token is being sent correctly

### "Service account key not found":
- Check file path in `.env`
- Ensure file exists and is readable

### "Invalid credentials":
- Regenerate service account key
- Update the JSON file
- Restart the server

---

## Next Steps

1. ✅ Complete Firebase console setup
2. ✅ Update backend dependencies (see updated `pubspec.yaml`)
3. ✅ Update Firebase services (see updated files)
4. ✅ Update controllers to use Firebase
5. ✅ Test all endpoints
6. ✅ Update mobile app to use Firebase Auth
