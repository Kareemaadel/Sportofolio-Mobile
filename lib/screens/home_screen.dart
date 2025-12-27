import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/app_theme.dart';
import '../widgets/post_widget.dart';
import '../models/post.dart';
import '../services/posts_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isNavBarVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    final scrollingDown = currentScrollOffset > _lastScrollOffset;
    final scrollingUp = currentScrollOffset < _lastScrollOffset;

    // Only update if scroll offset changed significantly (5px threshold)
    if ((currentScrollOffset - _lastScrollOffset).abs() > 5) {
      if (scrollingDown && _isNavBarVisible && currentScrollOffset > 50) {
        // Hide nav bar when scrolling down (after 50px)
        setState(() {
          _isNavBarVisible = false;
        });
      } else if (scrollingUp && !_isNavBarVisible) {
        // Show nav bar when scrolling up
        setState(() {
          _isNavBarVisible = true;
        });
      }
      _lastScrollOffset = currentScrollOffset;
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Posts Feed with top padding
            Positioned.fill(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // Top spacing for nav bar (fixed height)
                  const SliverToBoxAdapter(child: SizedBox(height: 68)),
                  // Posts Feed
                  _buildPostsSliverList(),
                ],
              ),
            ),
            // Animated Top Nav Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: _isNavBarVisible ? 0 : -68,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 12,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left side - App Logo and Title
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/logo.svg',
                          height: 32,
                          width: 32,
                          placeholderBuilder: (context) => const Icon(
                            Icons.sports_soccer,
                            color: AppTheme.accentColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sportofolio',
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Right side - Notification icon
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/bell.svg',
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          textColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSliverList() {
    return StreamBuilder<List<Post>>(
      stream: PostsService().getAllPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentColor,
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Error loading posts: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: AppTheme.textSecondaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share something!',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondaryColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = posts[index];

            // Skip posts with empty userId to avoid Firestore error
            if (post.userId.isEmpty) {
              return const SizedBox.shrink();
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(post.userId)
                  .get(),
              builder: (context, userSnapshot) {
                // Default values while loading
                String userName = 'User';
                String userDescription = '';
                String? profileImage;
                bool isVerified = false;

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  userName = userData?['name'] ?? 'User';
                  userDescription = userData?['role'] ?? '';
                  profileImage = userData?['profileImageUrl']?.toString();
                  isVerified = userData?['isVerified'] ?? false;
                }

                return PostWidget(
                  postId: post.postId,
                  postUserId: post.userId,
                  profileImage: profileImage,
                  userName: userName,
                  userDescription: userDescription.isNotEmpty
                      ? userDescription
                      : null,
                  timeAgo: timeago.format(post.createdAt),
                  content: post.caption,
                  postImage: post.mediaUrl.isNotEmpty ? post.mediaUrl : null,
                  postImages: null,
                  likes: post.likesCount,
                  comments: post.commentsCount,
                  reposts: 0,
                  shares: 0,
                  isVerified: isVerified,
                );
              },
            );
          }, childCount: posts.length),
        );
      },
    );
  }
}
