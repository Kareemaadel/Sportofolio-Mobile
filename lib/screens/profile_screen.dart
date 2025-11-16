import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _bio = '';
  String _club = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
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
    final borderColor = isDark ? AppTheme.borderColor : AppTheme.borderColorLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: backgroundColor,
                  automaticallyImplyLeading: false,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.grid_view, color: textColor),
                        onPressed: () {},
                      ),
                      Text(
                        'zeyad_waleeed',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: textColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
                      Positioned(
                        left: 20,
                        bottom: -60,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
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
                                backgroundImage: const AssetImage(
                                  'assets/images/profile pic.png',
                                ),
                              ),
                            ),
                            Positioned(
                              right: 5,
                              bottom: 5,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: textColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: textColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
                                        borderRadius: BorderRadius.circular(8),
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
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _club.isEmpty ? 'Al Ahly' : _club,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Football  Goalkeeper',
                                    style: TextStyle(
                                      color: textColor.withOpacity(
                                        0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                        const SizedBox(height: 60),
                        Text(
                          _name.isNotEmpty ? _name : 'Zeyad Waleed',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _bio.isNotEmpty
                              ? _bio
                              : 'Talented goalkeeper currently playing for Al Ahly, one of Egypt\'s most prestigious football clubs. Born and raised in Cairo',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('351', 'Following'),
                            Container(
                              width: 1,
                              height: 40,
                              color: borderColor,
                            ),
                            _buildStatColumn('1,457', 'Followers'),
                            Container(
                              width: 1,
                              height: 40,
                              color: borderColor,
                            ),
                            _buildStatColumn('64.7K', 'Likes'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.play_arrow, () {}),
                            _buildActionButton(Icons.info_outline, () {}),
                            _buildActionButton(Icons.favorite_border, () {}),
                            _buildActionButton(
                              Icons.emoji_events,
                              () {},
                              color: AppTheme.accentColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildInfoSection(),
                      ],
                    ),
                  ),
                ),
              ],
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
    final borderColor = isDark ? AppTheme.borderColor : AppTheme.borderColorLight;
    
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
        const SizedBox(height: 16),
        _buildCareerItem(
          'assets/images/Ahly.png',
          'Zamalek',
          'Goalkeeper',
          '2018-2022',
        ),
        const SizedBox(height: 16),
        _buildCareerItem(
          'assets/images/Ahly.png',
          'Zamalek',
          'Football player',
          '2015-2018',
        ),
        const SizedBox(height: 32),
        // Player stats section
        _buildPlayerStat('Heart', '70', 'BPM', Icons.favorite, Colors.red, textColor, secondaryTextColor, cardColor, borderColor),
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
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield, color: Colors.white),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                position,
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
            ],
          ),
        ),
        Text(
          years,
          style: TextStyle(color: secondaryTextColor, fontSize: 14),
        ),
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
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: secondaryTextColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    
    return SizedBox(
      width: 70,
      height: 48,
      child: IconButton(
        icon: Icon(icon, color: color ?? textColor),
        iconSize: 24,
        onPressed: onTap,
      ),
    );
  }
}
