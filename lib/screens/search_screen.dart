import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Map<String, dynamic>> _getAllPosts() {
    return [
      {
        'profileImage': 'assets/images/account.png',
        'userName': 'Zeyad Waleed',
        'userDescription': 'Basketball Player @Ahly',
        'timeAgo': '7h',
        'content':
            'When Josko met Thomas 😍\n\nA wholesome moment that this City fan will never, ever forget! 💙',
        'postImages': ['assets/images/post.png', 'assets/images/post.png'],
        'likes': 727,
        'comments': 2,
      },
      {
        'profileImage': 'assets/images/Madrid.png',
        'userName': 'Real Madrid',
        'userDescription': 'Official Account',
        'timeAgo': '1d',
        'content':
            '🇪🇸 7-0 🇦🇷\n💪 @gonzalogarcia7_\n🏅 2027 #U21EURO Qualifiers',
        'postImage': 'assets/images/post.png',
        'likes': 1240,
        'comments': 597,
      },
      {
        'profileImage': 'assets/images/Mancity.png',
        'userName': 'Manchester City',
        'userDescription': 'Official Account',
        'timeAgo': '2d',
        'content': 'Match day! 💙 Let\'s go City! #ManCity #PremierLeague',
        'postImage': 'assets/images/post.png',
        'likes': 2100,
        'comments': 845,
      },
      {
        'profileImage': 'assets/images/Ahly.png',
        'userName': 'Al Ahly SC',
        'userDescription': 'Official Account',
        'timeAgo': '3d',
        'content': 'Champions of Africa! 🏆🔴 #AlAhly #CAF',
        'postImage': 'assets/images/post.png',
        'likes': 3500,
        'comments': 1200,
      },
      {
        'profileImage': 'assets/images/Ronaldo.png',
        'userName': 'Cristiano Ronaldo',
        'userDescription': 'Al Nassr FC',
        'timeAgo': '4d',
        'content': 'Hard work pays off! ⚽💪 #CR7',
        'postImage': 'assets/images/post.png',
        'likes': 5200,
        'comments': 2100,
      },
      {
        'profileImage': 'assets/images/bellingham.jpeg',
        'userName': 'Jude Bellingham',
        'userDescription': 'Real Madrid',
        'timeAgo': '5d',
        'content': 'Living the dream at Madrid! 🤍 #HalaMadrid',
        'postImage': 'assets/images/post.png',
        'likes': 4100,
        'comments': 1800,
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredPosts() {
    if (_searchQuery.isEmpty) {
      return [];
    }

    final allPosts = _getAllPosts();
    final query = _searchQuery.toLowerCase();

    return allPosts.where((post) {
      final userName = (post['userName'] as String).toLowerCase();
      final content = (post['content'] as String).toLowerCase();
      return userName.contains(query) || content.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    if (_searchQuery.isEmpty) {
      return [];
    }

    final allPosts = _getAllPosts();
    final query = _searchQuery.toLowerCase();

    // Get unique users that match the search
    final userMap = <String, Map<String, dynamic>>{};
    
    for (var post in allPosts) {
      final userName = post['userName'] as String;
      final userNameLower = userName.toLowerCase();
      
      if (userNameLower.contains(query) && !userMap.containsKey(userName)) {
        userMap[userName] = {
          'profileImage': post['profileImage'],
          'userName': userName,
          'userDescription': post['userDescription'],
        };
      }
    }

    return userMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(29),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Users, Posts, Videos',
                    hintStyle: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: secondaryTextColor,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                            child: Icon(
                              Icons.close,
                              color: secondaryTextColor,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _performSearch,
                ),
              ),
            ),
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: textColor,
                unselectedLabelColor: secondaryTextColor,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                indicatorColor: textColor,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: 'Users'),
                  Tab(text: 'Videos'),
                  Tab(text: 'Posts'),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUsersTab(),
                  _buildVideosTab(),
                  _buildPostsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : const Color(0xFF6B7280);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for users, posts, and videos',
            style: GoogleFonts.poppins(color: secondaryTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : const Color(0xFF6B7280);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.poppins(
              color: secondaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: GoogleFonts.poppins(
              color: secondaryTextColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(user['profileImage'] as String),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['userName'] as String,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['userDescription'] as String,
                  style: GoogleFonts.poppins(
                    color: secondaryTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    final users = _getFilteredUsers();

    if (users.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUserItem(users[index]);
      },
    );
  }

  Widget _buildVideosTab() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    final posts = _getFilteredPosts();

    if (posts.isEmpty) {
      return _buildNoResultsState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildGridItem(posts[index]);
      },
    );
  }

  Widget _buildPostsTab() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    final posts = _getFilteredPosts();

    if (posts.isEmpty) {
      return _buildNoResultsState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildGridItem(posts[index]);
      },
    );
  }

  Widget _buildGridItem(Map<String, dynamic> post) {
    final String? imageUrl =
        post['postImage'] as String? ??
        (post['postImages'] as List<String>?)?.first;

    return Container(
      decoration: BoxDecoration(color: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Post Image
          if (imageUrl != null)
            Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      color: Color(0xFF3A3A3A),
                      size: 48,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              color: const Color(0xFF1E1E1E),
              child: const Center(
                child: Icon(Icons.image, color: Color(0xFF3A3A3A), size: 48),
              ),
            ),
          // Gradient overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),
          // User info and likes
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Row(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 12,
                  backgroundImage: AssetImage(post['profileImage'] as String),
                ),
                const SizedBox(width: 6),
                // Username
                Expanded(
                  child: Text(
                    post['userName'] as String,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Likes count
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(post['likes'] as int),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
