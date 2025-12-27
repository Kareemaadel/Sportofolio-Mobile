import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../services/posts_service.dart';
import '../theme/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  final String initialPostId;
  final String userId;

  const PostDetailScreen({
    super.key,
    required this.initialPostId,
    required this.userId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();
  List<Post> _posts = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    try {
      // Get all posts from this user
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .get();

      final posts = snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .toList();

      // Find the index of the initial post
      final initialIndex = posts.indexWhere(
        (post) => post.postId == widget.initialPostId,
      );

      setState(() {
        _posts = posts;
        _currentIndex = initialIndex >= 0 ? initialIndex : 0;
        _isLoading = false;
      });

      // Jump to the initial post
      if (initialIndex >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(initialIndex);
        });
      }
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final textSecondaryColor = isDark
        ? AppTheme.textSecondaryColor
        : AppTheme.textSecondaryColorLight;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Posts',
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'No posts found',
            style: GoogleFonts.poppins(color: textSecondaryColor, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(widget.userId).snapshots(),
          builder: (context, snapshot) {
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final username =
                userData?['username']?.toString().isNotEmpty == true
                ? userData!['username']
                : userData?['name'] ?? 'User';

            return Text(
              username,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostItem(post, textColor, textSecondaryColor, isDark);
        },
      ),
    );
  }

  Widget _buildPostItem(
    Post post,
    Color textColor,
    Color textSecondaryColor,
    bool isDark,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(post.userId).snapshots(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final name = userData?['name'] ?? 'User';
              final profileImageUrl = userData?['profileImageUrl'] ?? '';

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: GoogleFonts.poppins(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: textColor),
                      onPressed: () => _showPostMenu(context, post),
                    ),
                  ],
                ),
              );
            },
          ),

          // Post Image
          if (post.mediaUrl.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                post.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: isDark
                        ? AppTheme.cardColor
                        : AppTheme.cardColorLight,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: textSecondaryColor.withOpacity(0.5),
                        size: 64,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildSvgActionButton(
                  svgPath: 'assets/icons/heart.svg',
                  color: textSecondaryColor,
                  onTap: () {
                    // Like functionality
                  },
                ),
                const SizedBox(width: 4),
                _buildSvgActionButton(
                  svgPath: 'assets/icons/comment-dots.svg',
                  color: textSecondaryColor,
                  onTap: () {
                    // Comment functionality
                  },
                ),
                const SizedBox(width: 4),
                _buildSvgActionButton(
                  svgPath: 'assets/icons/share-square.svg',
                  color: textSecondaryColor,
                  onTap: () {
                    // Share functionality
                  },
                ),
              ],
            ),
          ),

          // Likes count
          if (post.likesCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${post.likesCount} ${post.likesCount == 1 ? 'like' : 'likes'}',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(post.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final userData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final username =
                      userData?['username']?.toString().isNotEmpty == true
                      ? userData!['username']
                      : userData?['name'] ?? 'User';

                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$username ',
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: post.caption,
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Comments count
          if (post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'View all ${post.commentsCount} comments',
                style: GoogleFonts.poppins(
                  color: textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),

          // Time ago
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              timeago.format(post.createdAt),
              style: GoogleFonts.poppins(
                color: textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSvgActionButton({
    required String svgPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          svgPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }

  void _showPostMenu(BuildContext context, Post post) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.cardColor
        : AppTheme.cardColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: textColor),
              title: Text(
                'Edit Caption',
                style: GoogleFonts.poppins(color: textColor, fontSize: 16),
              ),
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }
                _showEditCaptionDialog(context, post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Post',
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
              ),
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }
                _showDeleteConfirmation(context, post);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCaptionDialog(BuildContext context, Post post) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final backgroundColor = isDark
        ? AppTheme.cardColor
        : AppTheme.cardColorLight;

    final TextEditingController captionController = TextEditingController(
      text: post.caption,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Edit Caption',
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: captionController,
          style: GoogleFonts.poppins(color: textColor),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter new caption...',
            hintStyle: GoogleFonts.poppins(color: textColor.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: textColor.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCaption = captionController.text.trim();
              if (newCaption.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Caption cannot be empty',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (Navigator.of(context).canPop()) {
                Navigator.pop(context);
              }

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Updating post...', style: GoogleFonts.poppins()),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );

              // Update caption
              final success = await PostsService().updatePostCaption(
                post.postId,
                newCaption,
              );

              if (success) {
                // Reload posts to reflect changes
                await _loadPosts();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Caption updated successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to update caption',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Update',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Post post) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final backgroundColor = isDark
        ? AppTheme.cardColor
        : AppTheme.cardColorLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Delete Post',
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: GoogleFonts.poppins(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: textColor.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context);
              }

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Deleting post...', style: GoogleFonts.poppins()),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );

              // Delete post
              final success = await PostsService().deletePost(post.postId);

              if (success) {
                // If this was the last post or only post, go back to profile
                if (_posts.length == 1) {
                  if (mounted && Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Post deleted successfully',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  // Reload posts and stay on screen
                  await _loadPosts();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Post deleted successfully',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete post',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
