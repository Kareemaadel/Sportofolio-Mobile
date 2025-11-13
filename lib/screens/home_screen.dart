import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/post_widget.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showAppBarTitle) {
        setState(() {
          _showAppBarTitle = true;
        });
      } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
        setState(() {
          _showAppBarTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedOpacity(
                opacity: _showAppBarTitle ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    const Text(
                      'Sportofolio',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              background: Container(
                padding: const EdgeInsets.only(
                  left: AppTheme.spacingM,
                  right: AppTheme.spacingM,
                  top: AppTheme.spacingXL,
                  bottom: AppTheme.spacingM,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.sports_soccer,
                                color: AppTheme.textColor,
                                size: 20,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: SearchBarWidget(
                            placeholder: 'Search players, coaches...',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      _showNotifications(context);
                    },
                    tooltip: 'Notifications',
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.backgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: () {
                  // Navigate to messages
                },
                tooltip: 'Messages',
              ),
              const SizedBox(width: AppTheme.spacingS),
            ],
          ),
          // Posts Feed
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                },
                childCount: _getPosts().length,
              ),
            ),
          ),
        ],
      ),
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

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            _buildNotificationItem(
              'Karim Ashraf',
              'liked your post',
              'assets/images/karimashraf.png',
              '2h ago',
            ),
            _buildNotificationItem(
              'Kareem Adel',
              'Posted new video',
              'assets/images/kareemadel.png',
              '2h ago',
            ),
            _buildNotificationItem(
              'Abdelrahman el Kadi',
              'sent "please send me you portofolio as so.."',
              'assets/images/elkady.png',
              '2h ago',
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String name,
    String action,
    String image,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(image),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: action),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
