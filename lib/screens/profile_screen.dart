import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
=======
import '../theme/app_theme.dart';
import '../services/data_service.dart';
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
import '../services/theme_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeService? themeService;

  const ProfileScreen({super.key, this.themeService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
<<<<<<< HEAD
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data
=======
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
  String _name = '';
  String _email = '';
  String _bio = '';
<<<<<<< HEAD
  String _username = '';
  String _role = '';
  String _club = '';
  String _profileImageUrl = '';
  int _followingCount = 0;
  int _followersCount = 0;
  int _likesCount = 0;

=======
  String _club = '';
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
  bool _isLoading = true;
  int _selectedTab = 1; // 0: Videos, 1: Info, 2: Likes, 3: Trophy

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
<<<<<<< HEAD
    try {
      // Get current user
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            _name = userData['name'] ?? '';
            _email = userData['email'] ?? '';
            _bio = userData['bio'] ?? '';
            _username = userData['username'] ?? '';
            _role = userData['role'] ?? '';
            _club = userData['club'] ?? '';
            _profileImageUrl = userData['profileImageUrl'] ?? '';
            _isLoading = false;
          });

          // Fetch social counts (followers/following)
          await _loadSocialCounts(currentUser.uid);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSocialCounts(String userId) async {
    try {
      // Count followers
      QuerySnapshot followersSnapshot = await _firestore
          .collection('followers')
          .doc(userId)
          .collection('userFollowers')
          .get();

      // Count following
      QuerySnapshot followingSnapshot = await _firestore
          .collection('following')
          .doc(userId)
          .collection('userFollowing')
          .get();

      setState(() {
        _followersCount = followersSnapshot.docs.length;
        _followingCount = followingSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading social counts: $e');
    }
  }

=======
    await Future.delayed(const Duration(milliseconds: 300));
    final name = await DataService.getName();
    final bio = await DataService.getBio();
    final club = await DataService.getClub();
    setState(() {
      _name = name;
      _bio = bio;
      _club = club;
      _isLoading = false;
    });
  }

>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
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
        : AppTheme.textSecondaryColorLight;
    final cardColor = isDark ? AppTheme.cardColor : AppTheme.cardColorLight;
    final borderColor = isDark
        ? AppTheme.borderColor
        : AppTheme.borderColorLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage('assets/images/cover.webp'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                backgroundColor.withOpacity(0.7),
                                backgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Floating Navigation Bar
                      Positioned(
                        top: 40,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.qr_code,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // TODO: QR code action
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                    ),
<<<<<<< HEAD
                                    onPressed: () async {
                                      final result = await Navigator.push(
=======
                                    onPressed: () {
                                      Navigator.push(
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SettingsScreen(
                                            themeService: widget.themeService,
                                          ),
                                        ),
                                      );
<<<<<<< HEAD
                                      // Reload profile if settings were updated
                                      if (result == true) {
                                        _loadProfileData();
                                      }
=======
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: -75,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: backgroundColor,
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: cardColor,
<<<<<<< HEAD
                            backgroundImage: _profileImageUrl.isNotEmpty
                                ? NetworkImage(_profileImageUrl)
                                : null,
                            child: _profileImageUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: textColor.withOpacity(0.5),
                                  )
                                : null,
=======
                            backgroundImage: const AssetImage(
                              'assets/images/profile pic.png',
                            ),
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: -75,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
<<<<<<< HEAD
                          child: (_role.isNotEmpty || _club.isNotEmpty)
                              ? Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _role.isNotEmpty && _club.isNotEmpty
                                              ? '$_role • $_club'
                                              : _role.isNotEmpty
                                              ? _role
                                              : _club,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // Username removed from under club/role
                                      ],
                                    ),
                                  ],
                                )
                              : SizedBox(),
=======
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  DataService.getClubLogo(_club),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.shield,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _club.isEmpty ? 'Al Ahly' : _club,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Goalkeeper',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        Text(
<<<<<<< HEAD
                          _name.isNotEmpty ? _name : 'User',
=======
                          _name.isNotEmpty ? _name : 'Zeyad Waleed',
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
<<<<<<< HEAD
                        if (_username.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '@${_username}',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
=======
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                        const SizedBox(height: 8),
                        Text(
                          _bio.isNotEmpty
                              ? _bio
<<<<<<< HEAD
                              : 'No bio yet. Add one in settings!',
                          style: TextStyle(
                            color: _bio.isNotEmpty
                                ? secondaryTextColor
                                : secondaryTextColor.withOpacity(0.6),
                            fontSize: 12,
                            height: 1.5,
                            fontStyle: _bio.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
=======
                              : 'Talented goalkeeper currently playing for Al Ahly, one of Egypt\'s most prestigious football clubs. Born and raised in Cairo',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                            height: 1.5,
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
<<<<<<< HEAD
                            _buildStatColumn('$_followingCount', 'Following'),
                            Container(width: 1, height: 40, color: borderColor),
                            _buildStatColumn('$_followersCount', 'Followers'),
                            Container(width: 1, height: 40, color: borderColor),
                            _buildStatColumn('$_likesCount', 'Likes'),
=======
                            _buildStatColumn('351', 'Following'),
                            Container(width: 1, height: 40, color: borderColor),
                            _buildStatColumn('1,457', 'Followers'),
                            Container(width: 1, height: 40, color: borderColor),
                            _buildStatColumn('64.7K', 'Likes'),
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(height: 1, color: borderColor),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildActionButton(Icons.play_arrow, () {
                                setState(() {
                                  _selectedTab = 0;
                                });
                              }, isSelected: _selectedTab == 0),
                              _buildActionButton(Icons.info_outline, () {
                                setState(() {
                                  _selectedTab = 1;
                                });
                              }, isSelected: _selectedTab == 1),
                              _buildActionButton(
                                Icons.favorite_border,
                                () {
                                  setState(() {
                                    _selectedTab = 2;
                                  });
                                },
                                isSelected: _selectedTab == 2,
                              ),
                              _buildActionButton(Icons.emoji_events, () {
                                setState(() {
                                  _selectedTab = 3;
                                });
                              }, isSelected: _selectedTab == 3),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(height: 1, color: borderColor),
                        const SizedBox(height: 24),
                        _buildSelectedSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSelectedSection() {
    switch (_selectedTab) {
      case 0: // Videos
        return _buildVideosSection();
      case 1: // Info
        return _buildInfoSection();
      case 2: // Likes
        return _buildLikesSection();
      case 3: // Trophy
        return _buildTrophySection();
      default:
        return _buildInfoSection();
    }
  }

  Widget _buildVideosSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'Videos section coming soon',
          style: TextStyle(color: textColor, fontSize: 16),
<<<<<<< HEAD
        ),
      ),
    );
  }

  Widget _buildLikesSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'Likes section coming soon',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTrophySection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'Trophy section coming soon',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : AppTheme.textSecondaryColorLight;
    final cardColor = isDark ? AppTheme.cardColor : AppTheme.cardColorLight;
    final borderColor = isDark
        ? AppTheme.borderColor
        : AppTheme.borderColorLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Career history section - placeholder for now
        // TODO: Fetch career history from user profile
        if (_role.isNotEmpty)
          _buildCareerItem(
            'assets/images/Al Ahly.png',
            _role,
            'Current Position',
            'Now',
          ),
        if (_role.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No career information yet.\nAdd your role in settings!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor.withOpacity(0.6),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
=======
        ),
      ),
    );
  }

  Widget _buildLikesSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'Likes section coming soon',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTrophySection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'Trophy section coming soon',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : AppTheme.textSecondaryColorLight;
    final cardColor = isDark ? AppTheme.cardColor : AppTheme.cardColorLight;
    final borderColor = isDark
        ? AppTheme.borderColor
        : AppTheme.borderColorLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Career history section
        _buildCareerItem(
          DataService.getClubLogo(_club),
          _club.isEmpty ? 'Al Ahly' : _club,
          'Goalkeeper',
          '2022-Now',
        ),
        const SizedBox(height: 4),
        _buildCareerDashedLine(),
        const SizedBox(height: 4),
        _buildCareerItem(
          'assets/images/Zamalek.png',
          'Zamalek',
          'Goalkeeper',
          '2018-2022',
        ),
        const SizedBox(height: 4),
        _buildCareerDashedLine(),
        const SizedBox(height: 4),
        _buildCareerItem(
          'assets/images/Zamalek.png',
          'Zamalek',
          'Football player',
          '2015-2018',
        ),
>>>>>>> 51b834a1102217e446e03ec9fe85e11b5f647a25
        const SizedBox(height: 32),
        // Player stats section
        _buildPlayerStat(
          'Heart',
          '70',
          'BPM',
          Icons.favorite,
          Colors.red,
          textColor,
          secondaryTextColor,
          cardColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildPlayerStat(
          'Age',
          '18',
          'years',
          Icons.person,
          AppTheme.accentColor,
          textColor,
          secondaryTextColor,
          cardColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildPlayerStat(
          'Used Foot',
          'Right, Left',
          '',
          Icons.sports_soccer,
          AppTheme.accentColor,
          textColor,
          secondaryTextColor,
          cardColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildPlayerStat(
          'Length',
          '190',
          'cm',
          Icons.height,
          AppTheme.accentColor,
          textColor,
          secondaryTextColor,
          cardColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildPlayerStat(
          'Calories',
          '620.9',
          'kcal',
          Icons.local_fire_department,
          AppTheme.accentColor,
          textColor,
          secondaryTextColor,
          cardColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildPlayerStat(
          'Weight',
          '91',
          'gm',
          Icons.monitor_weight,
          AppTheme.accentColor,
          textColor,
          secondaryTextColor,
          cardColor,
          borderColor,
        ),
      ],
    );
  }

  Widget _buildCareerDashedLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: CustomPaint(
        size: const Size(1, 20),
        painter: DashedLinePainter(color: const Color(0xFF8A8B8F)),
      ),
    );
  }

  Widget _buildCareerItem(
    String logoPath,
    String clubName,
    String position,
    String years,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : AppTheme.textSecondaryColorLight;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            logoPath,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 16),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clubName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                position,
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(years, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildPlayerStat(
    String label,
    String value,
    String unit,
    IconData icon,
    Color iconColor,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit.isNotEmpty ? '$value $unit' : value,
                  style: TextStyle(color: secondaryTextColor, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'add here..',
            style: TextStyle(
              color: textColor.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : AppTheme.textSecondaryColorLight;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;

    return SizedBox(
      width: 70,
      height: 48,
      child: IconButton(
        icon: Icon(icon, color: isSelected ? AppTheme.accentColor : textColor),
        iconSize: 22,
        onPressed: onTap,
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    const dashCount = 3;

    for (int i = 0; i < dashCount; i++) {
      double startY = i * (dashHeight + dashSpace);
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
