import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _name = '';
  String _bio = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
    final name = await DataService.getName();
    final bio = await DataService.getBio();
    setState(() {
      _name = name;
      _bio = bio;
      _isLoading = false;
    });
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Enhanced Profile Header
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: AppTheme.backgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/cover.webp',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.accentColor,
                                    AppTheme.accentColorLight,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.backgroundColor.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(120),
                    child: Transform.translate(
                      offset: const Offset(0, 50),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.backgroundColor,
                                width: 4,
                              ),
                              boxShadow: AppTheme.elevatedShadow,
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: AppTheme.cardColor,
                              backgroundImage: const AssetImage(
                                'assets/images/profile pic.png',
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _name,
                                style: AppTheme.heading2.copyWith(
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingXS),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: AppTheme.textColor,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingL,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _bio,
                              style: AppTheme.bodyMedium.copyWith(
                                height: 1.6,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingL),
                            // Enhanced Stats
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                gradient: AppTheme.cardGradient,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                ),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('1M', 'Followers'),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: AppTheme.borderColor,
                                  ),
                                  _buildStatItem('30K', 'Ratings'),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: AppTheme.borderColor,
                                  ),
                                  _buildStatItem('150', 'Posts'),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingL),
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit Profile'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppTheme.spacingM,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.borderColor,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/settings');
                                    },
                                    icon: const Icon(Icons.settings),
                                    iconSize: 24,
                                    padding: const EdgeInsets.all(AppTheme.spacingM),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      // Enhanced Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: AppTheme.accentColor,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: AppTheme.textColor,
                          unselectedLabelColor: AppTheme.textSecondaryColor,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.grid_view),
                              text: 'Gallery',
                            ),
                            Tab(
                              icon: Icon(Icons.info_outline),
                              text: 'Info',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Enhanced Gallery Tab
                            GridView.builder(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: AppTheme.spacingS,
                                mainAxisSpacing: AppTheme.spacingS,
                              ),
                              itemCount: 9,
                              itemBuilder: (context, index) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(
                                    milliseconds: 200 + (index * 50),
                                  ),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.scale(
                                        scale: value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.cardGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.borderColor,
                                      ),
                                      boxShadow: AppTheme.cardShadow,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        color: AppTheme.secondaryColor,
                                        child: const Center(
                                          child: Icon(
                                            Icons.play_circle_outline,
                                            color: AppTheme.accentColor,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Enhanced Info Tab
                            Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: AppTheme.spacingM,
                                  mainAxisSpacing: AppTheme.spacingM,
                                  childAspectRatio: 1.1,
                                ),
                                itemCount: 8,
                                itemBuilder: (context, index) {
                                  final items = [
                                    {
                                      'icon': Icons.sports_soccer,
                                      'title': 'Current Club',
                                      'value': 'Al Ahly'
                                    },
                                    {
                                      'icon': Icons.favorite,
                                      'title': 'Heart Rate',
                                      'value': '70 BPM'
                                    },
                                    {
                                      'icon': Icons.calendar_today,
                                      'title': 'Age',
                                      'value': '18 years'
                                    },
                                    {
                                      'icon': Icons.directions_walk,
                                      'title': 'Used Foot',
                                      'value': 'Right, Left'
                                    },
                                    {
                                      'icon': Icons.straighten,
                                      'title': 'Length',
                                      'value': '190 cm'
                                    },
                                    {
                                      'icon': Icons.local_fire_department,
                                      'title': 'Calories',
                                      'value': '620.9 kcal'
                                    },
                                    {
                                      'icon': Icons.monitor_weight,
                                      'title': 'Weight',
                                      'value': '91 kg'
                                    },
                                    {
                                      'icon': Icons.history,
                                      'title': 'Previous Clubs',
                                      'value': 'Zamalek'
                                    },
                                  ];
                                  final item = items[index];
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                      milliseconds: 200 + (index * 50),
                                    ),
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
                                    child: Container(
                                      padding: const EdgeInsets.all(AppTheme.spacingM),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.cardGradient,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppTheme.borderColor,
                                        ),
                                        boxShadow: AppTheme.cardShadow,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(AppTheme.spacingS),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentColor
                                                  .withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              item['icon'] as IconData,
                                              color: AppTheme.accentColor,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(height: AppTheme.spacingS),
                                          Text(
                                            item['title'] as String,
                                            style: AppTheme.bodySmall.copyWith(
                                              fontSize: 11,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: AppTheme.spacingXS),
                                          Text(
                                            item['value'] as String,
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.heading3.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
