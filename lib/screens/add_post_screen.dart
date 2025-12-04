import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AddPostScreen extends StatefulWidget {
  final VoidCallback? onClose;
  
  const AddPostScreen({super.key, this.onClose});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _selectedImages = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addImage() {
    // TODO: Implement image picker
    if (_selectedImages.length < 4) {
      setState(() {
        _selectedImages.add('assets/images/post.png');
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _postContent() async {
    if (_textController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add some content or an image',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    // TODO: Implement actual post API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isPosting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Post created successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.accentColor,
        ),
      );

      _textController.clear();
      _selectedImages.clear();
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
                    backgroundImage:
                        const AssetImage('assets/images/account.png'),
                    backgroundColor: cardColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zeyad Waleed',
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Basketball Player @Ahly',
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
                      // Clear form data
                      setState(() {
                        _textController.clear();
                        _selectedImages.clear();
                      });
                      // Navigate to home using callback
                      widget.onClose?.call();
                    },
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20), // 20px padding from borders
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Input with padding
                    Container(
                      padding: const EdgeInsets.all(16), // 16px internal padding
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

                    // Images Grid
                    if (_selectedImages.isNotEmpty) ...[
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedImages.length) {
                              // Add button
                              return GestureDetector(
                                onTap: _addImage,
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.2),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: secondaryTextColor,
                                    size: 32,
                                  ),
                                ),
                              );
                            }

                            // Image preview
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      _selectedImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
                  _buildBottomAction(
                    icon: 'assets/icons/image.svg',
                    onTap: _addImage,
                    color: textColor,
                  ),
                  const SizedBox(width: 16),
                  _buildBottomAction(
                    icon: 'assets/icons/video.svg',
                    onTap: () {
                      // TODO: Implement video picker
                    },
                    color: textColor,
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

  Widget _buildBottomAction({
    dynamic icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: icon is String
            ? SvgPicture.asset(
                icon,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  color.withOpacity(0.7),
                  BlendMode.srcIn,
                ),
              )
            : Icon(
                icon as IconData,
                size: 22,
                color: color.withOpacity(0.7),
              ),
      ),
    );
  }
}
