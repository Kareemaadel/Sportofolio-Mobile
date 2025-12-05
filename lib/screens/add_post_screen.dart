import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/cloudinary_service.dart';
import '../services/posts_service.dart';

class AddPostScreen extends StatefulWidget {
  final VoidCallback? onClose;
  
  const AddPostScreen({super.key, this.onClose});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final PostsService _postsService = PostsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  File? _selectedImage;
  bool _isPosting = false;
  String _userName = '';
  String _userRole = '';
  String _userClub = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _userName = data?['name'] ?? 'User';
            _userRole = data?['role'] ?? '';
            _userClub = data?['club'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.cardColor
          : AppTheme.cardColorLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final textColor = Theme.of(context).brightness == Brightness.dark
            ? AppTheme.textColor
            : AppTheme.textColorLight;
        
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: textColor),
                title: Text(
                  'Choose from gallery',
                  style: GoogleFonts.poppins(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: textColor),
                title: Text(
                  'Take a photo',
                  style: GoogleFonts.poppins(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _postContent() async {
    // Validation
    if (_textController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add a caption or select an image',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an image',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      print('🔄 Starting post creation...');
      print('📝 Caption: ${_textController.text.trim()}');
      print('📸 Image selected: ${_selectedImage!.path}');
      
      // 1. Upload image to Cloudinary
      print('☁️ Uploading to Cloudinary...');
      String? mediaUrl = await _cloudinaryService.uploadImage(
        _selectedImage!,
        folder: 'sportofolio/posts',
      );

      if (mediaUrl == null) {
        throw Exception('Cloudinary upload returned null URL');
      }
      
      print('✅ Cloudinary upload successful!');
      print('🔗 URL: $mediaUrl');

      // 2. Create post in Firestore
      print('💾 Saving to Firestore...');
      String? postId = await _postsService.createPost(
        caption: _textController.text.trim(),
        mediaUrl: mediaUrl,
      );

      if (postId == null) {
        throw Exception('Firestore createPost returned null postId');
      }
      
      print('✅ Post created successfully!');
      print('📄 Post ID: $postId');

      // Success!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Post created successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.accentColor,
          ),
        );

        // Clear form
        _textController.clear();
        setState(() {
          _selectedImage = null;
        });

        // Close screen after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onClose?.call();
          }
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error creating post: $e');
      print('📍 Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create post: ${e.toString()}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;
    final cardColor = isDark ? AppTheme.cardColor : AppTheme.cardColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? AppTheme.textSecondaryColor
        : AppTheme.textSecondaryColorLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: cardColor,
                    child: Icon(
                      Icons.person,
                      color: textColor.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.isNotEmpty ? _userName : 'Loading...',
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_userRole.isNotEmpty)
                          Text(
                            _userClub.isNotEmpty
                                ? '$_userRole • $_userClub'
                                : _userRole,
                            style: GoogleFonts.poppins(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor, size: 24),
                    onPressed: () {
                      _textController.clear();
                      setState(() {
                        _selectedImage = null;
                      });
                      widget.onClose?.call();
                    },
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        minLines: 3,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What\'s happening?',
                          hintStyle: GoogleFonts.poppins(
                            color: secondaryTextColor,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image Preview
                    if (_selectedImage != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: textColor),
                    onPressed: _showImageSourceSelector,
                  ),
                  const Spacer(),
                  // Post Button
                  ElevatedButton(
                    onPressed: _isPosting ? null : _postContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: AppTheme.accentColor.withOpacity(0.5),
                    ),
                    child: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'POST',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
