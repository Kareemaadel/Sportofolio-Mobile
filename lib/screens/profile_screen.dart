import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../services/posts_service.dart';
import '../models/post.dart';
import 'settings_screen.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final dynamic themeService;
  const ProfileScreen({Key? key, this.themeService}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PostsService _postsService = PostsService();

  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<DocumentSnapshot>? _getUserDataStream() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore.collection('users').doc(currentUser.uid).snapshots();
    }
    return null;
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
    final cardColor = isDark ? AppTheme.cardColor : AppTheme.cardColorLight;

    final userDataStream = _getUserDataStream();

    if (userDataStream == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Please log in to view profile',
            style: GoogleFonts.poppins(color: textColor, fontSize: 16),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: userDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Text(
                'Error loading profile',
                style: GoogleFonts.poppins(color: textColor, fontSize: 16),
              ),
            ),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final String name = userData?['name'] ?? 'User Name';
        final String username = userData?['username'] ?? '';
        final String bio = userData?['bio'] ?? '';
        final String role = userData?['role'] ?? '';
        final String club = userData?['club'] ?? '';
        final String profileImageUrl = userData?['profileImageUrl'] ?? '';
        final bool isVerified = userData?['isVerified'] ?? false;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: backgroundColor,
                  elevation: 0,
                  pinned: true,
                  floating: false,
                  expandedHeight: 0,
                  title: Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: textColor,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              themeService:
                                  widget.themeService as ThemeService?,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Profile Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Picture
                      _buildProfilePicture(
                        profileImageUrl,
                        cardColor,
                        textColor,
                      ),

                      const SizedBox(height: 16),

                      // Username (main title) with verification badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            username.isNotEmpty ? '@$username' : name,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ],
                        ],
                      ),

                      // Role and Club
                      if (role.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.accentColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            club.isNotEmpty ? '$role • $club' : role,
                            style: GoogleFonts.poppins(
                              color: AppTheme.accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      // Bio
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            bio,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Stats Row
                      _buildStatsRow(
                        userData?['uid'] ?? _auth.currentUser?.uid ?? '',
                        textColor,
                        textSecondaryColor,
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Divider(
                        color: isDark
                            ? AppTheme.borderColor
                            : AppTheme.borderColorLight,
                        height: 1,
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.accentColor,
                      indicatorWeight: 2,
                      labelColor: textColor,
                      unselectedLabelColor: textSecondaryColor,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: [
                        Tab(
                          icon: Icon(
                            Icons.grid_on,
                            color: _selectedTabIndex == 0
                                ? textColor
                                : textSecondaryColor,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.bookmark_border,
                            color: _selectedTabIndex == 1
                                ? textColor
                                : textSecondaryColor,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.video_library_outlined,
                            color: _selectedTabIndex == 2
                                ? textColor
                                : textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor,
                  ),
                ),

                // Tab Content
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsGrid(
                        userData?['uid'] ?? _auth.currentUser?.uid ?? '',
                        textColor,
                        textSecondaryColor,
                      ),
                      _buildSavedGrid(textSecondaryColor),
                      _buildVideosGrid(textSecondaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture(
    String profileImageUrl,
    Color cardColor,
    Color textColor,
  ) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: cardColor,
      backgroundImage: profileImageUrl.isNotEmpty
          ? NetworkImage(profileImageUrl)
          : null,
      child: profileImageUrl.isEmpty
          ? Icon(Icons.person, size: 50, color: textColor.withOpacity(0.5))
          : null,
    );
  }

  Widget _buildStatsRow(
    String userId,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FutureBuilder<int>(
            future: _postsService.getUserPostsCount(userId),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return _buildStatItem(
                count.toString(),
                'Posts',
                textColor,
                textSecondaryColor,
              );
            },
          ),
          Container(
            width: 1,
            height: 40,
            color: textSecondaryColor.withOpacity(0.2),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: _getUserDataStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildStatItem(
                  '0',
                  'Followers',
                  textColor,
                  textSecondaryColor,
                );
              }
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final followers = userData?['followers'] ?? 0;
              return _buildStatItem(
                followers.toString(),
                'Followers',
                textColor,
                textSecondaryColor,
              );
            },
          ),
          Container(
            width: 1,
            height: 40,
            color: textSecondaryColor.withOpacity(0.2),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: _getUserDataStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildStatItem(
                  '0',
                  'Following',
                  textColor,
                  textSecondaryColor,
                );
              }
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final following = userData?['following'] ?? 0;
              return _buildStatItem(
                following.toString(),
                'Following',
                textColor,
                textSecondaryColor,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String count,
    String label,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(color: textSecondaryColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPostsGrid(
    String userId,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return StreamBuilder<List<Post>>(
      stream: _postsService.getUserPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading posts',
              style: GoogleFonts.poppins(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.grid_on,
            title: 'No Posts Yet',
            subtitle: 'Start sharing your sports moments!',
            textColor: textColor,
            textSecondaryColor: textSecondaryColor,
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      initialPostId: post.postId,
                      userId: userId,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(color: AppTheme.cardColor),
                child: post.mediaUrl.isNotEmpty
                    ? Image.network(
                        post.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.cardColor,
                            child: Icon(
                              Icons.broken_image,
                              color: textSecondaryColor.withOpacity(0.5),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.accentColor,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          color: textSecondaryColor.withOpacity(0.5),
                          size: 40,
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedGrid(Color textSecondaryColor) {
    return _buildEmptyState(
      icon: Icons.bookmark_border,
      title: 'No Saved Posts',
      subtitle: 'Save posts you want to see later',
      textColor: AppTheme.textColor,
      textSecondaryColor: textSecondaryColor,
    );
  }

  Widget _buildVideosGrid(Color textSecondaryColor) {
    return _buildEmptyState(
      icon: Icons.video_library_outlined,
      title: 'No Videos',
      subtitle: 'Upload your game highlights',
      textColor: AppTheme.textColor,
      textSecondaryColor: textSecondaryColor,
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color textSecondaryColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: textSecondaryColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(color: textSecondaryColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
