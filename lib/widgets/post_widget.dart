import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/posts_service.dart';

class PostWidget extends StatefulWidget {
  final String postId;
  final String postUserId;
  final String? profileImage;
  final String userName;
  final String? userDescription;
  final String timeAgo;
  final String content;
  final String? postImage;
  final List<String>? postImages;
  final int likes;
  final int comments;
  final int reposts;
  final int shares;
  final bool isVerified;

  const PostWidget({
    super.key,
    required this.postId,
    required this.postUserId,
    this.profileImage,
    this.userName = 'Zeyad Waleed',
    this.userDescription,
    this.timeAgo = '7h',
    this.content =
        'When Josko met Thomas 😍\n\nA wholesome moment that this City fan will never, ever forget! 💙\n\nTogether, we can use our #PowerForGood to end bullying, for good 🛡️ #AntiBullyingWeek',
    this.postImage,
    this.postImages,
    this.likes = 0,
    this.comments = 0,
    this.reposts = 0,
    this.shares = 0,
    this.isVerified = false,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('likes')
          .doc(currentUserId)
          .get();

      if (mounted) {
        setState(() {
          _isLiked = doc.exists;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking like status: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleLike() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Optimistic update
    setState(() => _isLiked = !_isLiked);

    try {
      final likeRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('likes')
          .doc(currentUserId);

      if (_isLiked) {
        // Add like
        await likeRef.set({
          'userId': currentUserId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        await PostsService().incrementLikes(widget.postId);
      } else {
        // Remove like
        await likeRef.delete();
        await PostsService().decrementLikes(widget.postId);
      }
    } catch (e) {
      print('Error toggling like: $e');
      // Revert optimistic update on error
      if (mounted) {
        setState(() => _isLiked = !_isLiked);
      }
    }
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.cardColor
        : AppTheme.cardColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.accentColor, size: 28),
            const SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '$feature feature will be available soon!',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? AppTheme.textSecondaryColor
        : AppTheme.textSecondaryColorLight;
    final backgroundColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;

    // Get images list
    final images =
        widget.postImages ??
        (widget.postImage != null ? [widget.postImage!] : <String>[]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: secondaryTextColor.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Profile picture + username info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    widget.profileImage != null &&
                        widget.profileImage!.isNotEmpty
                    ? (widget.profileImage!.startsWith('http')
                          ? NetworkImage(widget.profileImage!) as ImageProvider
                          : AssetImage(widget.profileImage!))
                    : null,
                child:
                    widget.profileImage == null || widget.profileImage!.isEmpty
                    ? Text(
                        widget.userName.isNotEmpty
                            ? widget.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Username, verified, time, description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.userName,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue,
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          widget.timeAgo,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (widget.userDescription != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.userDescription!,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Menu button
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: secondaryTextColor,
                  size: 22,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 30),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content text - aligned with profile picture
          _buildContentWithMentions(widget.content, textColor),

          // Images (if any) - aligned with profile picture
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildImagesGrid(images, secondaryTextColor),
          ],

          const SizedBox(height: 12),

          // Action buttons - aligned with profile picture
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSvgActionButton(
                svgPath: _isLiked
                    ? 'assets/icons/heart (1).svg'
                    : 'assets/icons/heart.svg',
                count: widget.likes,
                color: _isLiked ? Colors.red : secondaryTextColor,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 16),
              _buildSvgActionButton(
                svgPath: 'assets/icons/comment-dots.svg',
                count: widget.comments,
                color: secondaryTextColor,
                onTap: () {
                  _showFeatureComingSoon(context, 'Comment');
                },
              ),
              const SizedBox(width: 16),
              _buildSvgActionButton(
                svgPath: 'assets/icons/share-square.svg',
                count: widget.reposts,
                color: secondaryTextColor,
                onTap: () {
                  _showFeatureComingSoon(context, 'Share');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithMentions(String content, Color textColor) {
    final mentionRegex = RegExp(r'@\w+');
    final matches = mentionRegex.allMatches(content);

    if (matches.isEmpty) {
      // No mentions, return simple text
      return Text(
        content,
        style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
      );
    }

    // Build rich text with colored mentions
    List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      // Add text before mention
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
          ),
        );
      }

      // Add mention with light blue color
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            color: Colors.lightBlue,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after last mention
    if (lastIndex < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastIndex),
          style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildImagesGrid(List<String> images, Color borderColor) {
    if (images.length == 1) {
      // Single image
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildImage(
          images[0],
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          borderColor: borderColor,
        ),
      );
    } else if (images.length == 2) {
      // Two images side by side
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 320,
          child: Row(
            children: [
              Expanded(
                child: _buildImage(
                  images[0],
                  height: 320,
                  fit: BoxFit.cover,
                  borderColor: borderColor,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: _buildImage(
                  images[1],
                  height: 320,
                  fit: BoxFit.cover,
                  borderColor: borderColor,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Multiple images in grid (3 or 4 images)
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 320,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: images.length > 4 ? 4 : images.length,
            itemBuilder: (context, index) {
              return _buildImage(
                images[index],
                fit: BoxFit.cover,
                borderColor: borderColor,
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildImage(
    String imagePath, {
    double? width,
    double? height,
    BoxFit? fit,
    required Color borderColor,
  }) {
    final bool isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height ?? 300,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                color: borderColor,
                size: 48,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height ?? 300,
            color: Colors.grey[850],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height ?? 300,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                color: borderColor,
                size: 48,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildSvgActionButton({
    required String svgPath,
    required int count,
    required Color color,
    required VoidCallback onTap,
    bool showCount = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 35,
              child: showCount && count > 0
                  ? Text(
                      count.toString(),
                      style: TextStyle(color: color, fontSize: 13),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
