import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/post_widget.dart';

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
      body: Stack(
        children: [
          // Posts Feed with top padding
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top spacing for nav bar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: _isNavBarVisible ? 68 : 0,
                  ),
                ),
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
              padding: const EdgeInsets.only(top: 16, bottom: 12, left: 16, right: 16),
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
                  // Right side - Notification and Message icons
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/bell.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    ),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/paper-plane.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    ),
                    onPressed: () {
                      // TODO: Navigate to messages
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSliverList() {
    return SliverList(
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
                userDescription: posts[index]['userDescription'] as String?,
                timeAgo: posts[index]['timeAgo']!,
                content: posts[index]['content']!,
                postImage: posts[index]['postImage'],
                postImages: posts[index]['postImages'] as List<String>?,
                likes: posts[index]['likes'] as int,
                comments: posts[index]['comments'] as int,
                reposts: (posts[index]['reposts'] as int?) ?? 0,
                shares: (posts[index]['shares'] as int?) ?? 0,
              ),
            );
          }
          return null;
        },
        childCount: _getPosts().length,
      ),
    );
  }

  List<Map<String, dynamic>> _getPosts() {
    return [
      {
        'profileImage': 'assets/images/account.png',
        'userName': 'Zeyad Waleed',
        'userDescription': 'Basketball Player @Ahly',
        'timeAgo': '7h',
        'content':
            'When Josko met Thomas 😍\n\nA wholesome moment that this City fan will never, ever forget! 💙\n\nTogether, we can use our #PowerForGood to end bullying, for good 🛡️ #AntiBullyingWeek',
        'postImages': ['assets/images/post.png', 'assets/images/post.png'],
        'likes': 727,
        'comments': 2,
        'reposts': 8,
        'shares': 1,
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
        'reposts': 125,
        'shares': 45,
      },
      {
        'profileImage': 'assets/images/Mancity.png',
        'userName': 'Manchester City',
        'userDescription': 'Football Club',
        'timeAgo': '2d',
        'content': '⚪ Match day ready! 💪\n#ManCity',
        'postImage': 'assets/images/post.png',
        'likes': 892,
        'comments': 423,
        'reposts': 87,
        'shares': 34,
      },
    ];
  }
}
