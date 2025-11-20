import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';
import '../services/theme_service.dart';
import 'edit_name_screen.dart';
import 'edit_username_screen.dart';
import 'edit_bio_screen.dart';
import 'edit_role_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeService? themeService;

  const SettingsScreen({super.key, this.themeService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedSection = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _urlController;

  // Settings state
  String _pronouns = 'he/him';
  String _selectedClub = 'Al Ahly';
  String _role = 'Goalkeeper';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
    _urlController = TextEditingController();
    _loadSettings();

    // Listen to theme changes
    widget.themeService?.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadSettings() async {
    final name = await DataService.getName();
    final email = await DataService.getEmail();
    final bio = await DataService.getBio();
    final pronouns = await DataService.getPronouns();
    final url = await DataService.getUrl();
    final club = await DataService.getClub();
    final role = await DataService.getRole();

    setState(() {
      _nameController.text = name;
      _emailController.text = email;
      _bioController.text = bio;
      _pronouns = pronouns;
      _urlController.text = url;
      _selectedClub = club;
      _role = role;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      await Future.delayed(const Duration(milliseconds: 500)); // Simulate save

      await DataService.setName(_nameController.text);
      await DataService.setEmail(_emailController.text);
      await DataService.setBio(_bioController.text);
      await DataService.setPronouns(_pronouns);
      await DataService.setUrl(_urlController.text);

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppTheme.spacingS),
                Text('Profile saved successfully!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(AppTheme.spacingM),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.themeService?.removeListener(_onThemeChanged);
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final borderColor = isDark
        ? AppTheme.borderColor
        : AppTheme.borderColorLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit profile',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile picture
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 58,
                    backgroundImage: AssetImage(
                      'assets/images/profile pic.png',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Form fields
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildProfileItem(
                    label: 'Name',
                    value: _nameController.text.isEmpty
                        ? 'ZEYAD'
                        : _nameController.text,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditNameScreen(currentName: _nameController.text),
                        ),
                      );
                      if (result == true) {
                        _loadSettings();
                      }
                    },
                    isFirst: true,
                  ),
                  _buildProfileItem(
                    label: 'Email',
                    value: _emailController.text.isEmpty
                        ? 'zeyadwaleed_7'
                        : _emailController.text,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUsernameScreen(
                            currentUsername: _emailController.text,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadSettings();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Basic info',
                style: TextStyle(
                  color: Color(0xFF8A8B8F),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBioItem(
                    label: 'Bio',
                    value: _bioController.text.isEmpty
                        ? '..'
                        : _bioController.text,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditBioScreen(currentBio: _bioController.text),
                        ),
                      );
                      if (result == true) {
                        _loadSettings();
                      }
                    },
                  ),
                  _buildClubDropdown(),
                  _buildProfileItem(
                    label: 'Role',
                    value: _role,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditRoleScreen(currentRole: _role),
                        ),
                      );
                      if (result == true) {
                        _loadSettings();
                      }
                    },
                  ),
                ],
              ),
            ),
            // Additional sections from original settings
            const SizedBox(height: 30),
            _buildAppearanceSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required String label,
    required String value,
    required VoidCallback onTap,
    Color? valueColor,
    bool isFirst = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          border: Border(
            top: isFirst
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF1F1F1F), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppTheme.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8A8B8F),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioItem({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFF101010)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8A8B8F),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(color: AppTheme.textColor, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubDropdown() {
    final clubs = DataService.clubLogos;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        border: Border(top: BorderSide(color: Color(0xFF1F1F1F), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Club',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClub,
                isExpanded: true,
                alignment: Alignment.centerRight,
                dropdownColor: AppTheme.cardColor,
                icon: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8A8B8F),
                  size: 20,
                ),
                selectedItemBuilder: (BuildContext context) {
                  return clubs.keys.map((String club) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          club,
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            clubs[club]!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
                items: clubs.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            entry.value,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    setState(() {
                      _selectedClub = newValue;
                    });
                    await DataService.setClub(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final isDarkMode = widget.themeService?.isDarkMode ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Appearance',
            style: TextStyle(
              color: Color(0xFF8A8B8F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(color: AppTheme.textColor, fontSize: 16),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    if (widget.themeService != null) {
                      widget.themeService!.toggleTheme();
                    }
                  },
                  activeColor: AppTheme.accentColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
