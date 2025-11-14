import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/post_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // App Bar with centered tabs
          Container(
            padding: const EdgeInsets.only(top: AppTheme.spacingM),
            child: Row(
              children: [
                // Left spacer for centering
                const SizedBox(width: 56),
                // Centered tabs
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.textColor,
                    indicatorWeight: 3,
                    labelColor: AppTheme.textColor,
                    unselectedLabelColor: AppTheme.textSecondaryColor,
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: 'Following'),
                      Tab(text: 'For You'),
                    ],
                  ),
                ),
                // Right side - no search icon per request
                const SizedBox(width: 56),
              ],
            ),
          ),
          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsList(),
                _buildPostsList(), // Same content for now
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Posts Feed
        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final posts = _getPosts();
              if (index < posts.length) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: PostWidget(
                    profileImage: posts[index]['profileImage']!,
                    userName: posts[index]['userName']!,
                    timeAgo: posts[index]['timeAgo']!,
                    content: posts[index]['content']!,
                    postImage: posts[index]['postImage'],
                    likes: posts[index]['likes'] as int,
                    comments: posts[index]['comments'] as int,
                    reposts: posts[index]['reposts'] as int,
                  ),
                );
              }
              return null;
            }, childCount: _getPosts().length),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getPosts() {
    return [
      {
        'profileImage': 'assets/images/profilepostpic.png',
        'userName': 'Real Madrid C.F.',
        'timeAgo': '2h',
        'content':
            '💪 Final session ahead of Rayo clash!\n🔥 ¡Último entrenamiento antes del partido contra el Rayo!\n#RMCity #RayoRealMadrid',
        'postImage': 'assets/images/post.png',
        'likes': 1240,
        'comments': 89,
        'reposts': 45,
      },
      {
        'profileImage': 'assets/images/profilepostpic.png',
        'userName': 'Barcelona FC',
        'timeAgo': '5h',
        'content': 'Match day! Ready for the game! 🏆⚽\n#ViscaElBarca',
        'postImage': 'assets/images/post.png',
        'likes': 892,
        'comments': 67,
        'reposts': 23,
      },
      {
        'profileImage': 'assets/images/profilepostpic.png',
        'userName': 'Manchester City',
        'timeAgo': '1d',
        'content':
            'Training session completed! 💪\nGreat work from the team today!',
        'postImage': 'assets/images/post.png',
        'likes': 567,
        'comments': 34,
        'reposts': 12,
      },
    ];
  }
}
