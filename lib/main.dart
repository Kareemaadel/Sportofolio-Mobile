import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'services/theme_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SportofolioApp());
}

class SportofolioApp extends StatefulWidget {
  const SportofolioApp({super.key});

  @override
  State<SportofolioApp> createState() => _SportofolioAppState();
}

class _SportofolioAppState extends State<SportofolioApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sportofolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.themeMode,
      home: MainNavigationScreen(themeService: _themeService),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final ThemeService themeService;

  const MainNavigationScreen({super.key, required this.themeService});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const SearchScreen(),
      const Placeholder(), // Create/Add screen
      const Placeholder(), // Apply screen
      const ProfileScreen(),
    ];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardColor : AppTheme.cardColorLight;
    final unselectedColor = isDark
        ? AppTheme.textSecondaryColor
        : AppTheme.textSecondaryColorLight;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: unselectedColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/home (1).svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(AppTheme.accentColor, BlendMode.srcIn),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(AppTheme.accentColor, BlendMode.srcIn),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/add.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/add.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(AppTheme.accentColor, BlendMode.srcIn),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/apply.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/apply.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(AppTheme.accentColor, BlendMode.srcIn),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/user.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/user.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(AppTheme.accentColor, BlendMode.srcIn),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
