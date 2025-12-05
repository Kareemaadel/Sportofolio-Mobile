import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../screens/login_screen.dart';
import 'edit_name_screen.dart';
import 'edit_username_screen.dart';
import 'edit_bio_screen.dart';
import 'edit_role_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeService? themeService;

  const SettingsScreen({super.key, this.themeService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- Image picker and upload methods (must be at top for reference) ---
  Future<void> _uploadProfileImage(XFile imageFile) async {
    setState(() {
      _isSaving = true;
    });
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/${currentUser.uid}.jpg',
        );
        final file = File(imageFile.path);
        if (!file.existsSync()) {
          throw Exception('Selected image file does not exist.');
        }
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;
        if (snapshot.state == TaskState.success) {
          final downloadUrl = await storageRef.getDownloadURL();
          setState(() {
            _profileImageUrl = downloadUrl;
          });
          await _firestore.collection('users').doc(currentUser.uid).update({
            'profileImageUrl': downloadUrl,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile image updated!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          throw Exception('Upload failed: ${snapshot.state}');
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      String errorMsg = e is FirebaseException
          ? e.message ?? e.code
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $errorMsg'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
        await _uploadProfileImage(pickedFile);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSaving = false;
  bool _isLoading = true;
  bool _dataChanged = false; // Track if any data was changed

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _roleController;

  // Additional fields
  String _club = '';
  String _profileImageUrl = '';

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  // Move these methods above their first use

  // --- Image picker and upload methods (move to top for reference) ---

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _roleController = TextEditingController();
    _loadSettings();

    // Listen to theme changes
    widget.themeService?.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadSettings() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            _nameController.text = userData['name'] ?? '';
            _usernameController.text = userData['username'] ?? '';
            _bioController.text = userData['bio'] ?? '';
            _roleController.text = userData['role'] ?? '';
            _club = userData['club'] ?? '';
            _profileImageUrl = userData['profileImageUrl'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Update Firestore
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
          'role': _roleController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
          if (_profileImageUrl.isNotEmpty) 'profileImageUrl': _profileImageUrl,
        });

        setState(() {
          _isSaving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: AppTheme.spacingS),
                  Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(AppTheme.spacingM),
            ),
          );

          // Return true to indicate profile was updated
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.themeService?.removeListener(_onThemeChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final borderColor = isDark
        ? AppTheme.borderColor
        : AppTheme.borderColorLight;
    final cardColor = isDark ? AppTheme.cardColor : AppTheme.cardColorLight;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dataChanged);
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context, _dataChanged),
          ),
          title: Text(
            'Edit profile',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile picture
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: cardColor,
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path))
                          : (_profileImageUrl.isNotEmpty
                                    ? NetworkImage(_profileImageUrl)
                                    : null)
                                as ImageProvider?,
                      child: (_profileImageUrl.isEmpty && _pickedImage == null)
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: textColor.withOpacity(0.5),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Form fields
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildProfileItem(
                      label: 'Name',
                      value: _nameController.text.isEmpty
                          ? 'Add name'
                          : _nameController.text,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNameScreen(
                              currentName: _nameController.text,
                            ),
                          ),
                        );
                        if (result == true) {
                          _dataChanged = true;
                          _loadSettings();
                        }
                      },
                      isFirst: true,
                    ),
                    _buildProfileItem(
                      label: 'Username',
                      value: _usernameController.text.isEmpty
                          ? 'Add username'
                          : _usernameController.text,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUsernameScreen(
                              currentUsername: _usernameController.text,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadSettings();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Basic info',
                  style: TextStyle(
                    color: Color(0xFF8A8B8F),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBioItem(
                      label: 'Bio',
                      value: _bioController.text.isEmpty
                          ? 'Add bio..'
                          : _bioController.text,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditBioScreen(currentBio: _bioController.text),
                          ),
                        );
                        if (result == true) {
                          _loadSettings();
                        }
                      },
                    ),
                    _buildProfileItem(
                      label: 'Role',
                      value: _roleController.text.isEmpty
                          ? 'Add role'
                          : _club.isNotEmpty
                          ? '${_roleController.text} • $_club'
                          : _roleController.text,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRoleScreen(
                              currentRole: _roleController.text,
                              currentClub: _club,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadSettings();
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Logout section
              const SizedBox(height: 30),
              _buildLogoutSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Logout',
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF8A8B8F)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8A8B8F)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Navigate to login screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Widget _buildLogoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Account',
            style: TextStyle(
              color: Color(0xFF8A8B8F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _handleLogout,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required String label,
    required String value,
    required VoidCallback onTap,
    Color? valueColor,
    bool isFirst = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          border: Border(
            top: isFirst
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF1F1F1F), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppTheme.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8A8B8F),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioItem({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFF101010)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8A8B8F),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(color: AppTheme.textColor, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
