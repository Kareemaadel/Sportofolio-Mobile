import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
  bool _darkMode = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
    _urlController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await DataService.getName();
    final email = await DataService.getEmail();
    final bio = await DataService.getBio();
    final pronouns = await DataService.getPronouns();
    final url = await DataService.getUrl();

    setState(() {
      _nameController.text = name;
      _emailController.text = email;
      _bioController.text = bio;
      _pronouns = pronouns;
      _urlController.text = url;
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
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Enhanced Sidebar (for larger screens)
          if (MediaQuery.of(context).size.width > 600)
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                border: Border(
                  right: BorderSide(color: AppTheme.borderColor, width: 1),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                children: [
                  const SizedBox(height: AppTheme.spacingS),
                  _buildSidebarItem(Icons.person, 'Public profile', 0),
                  _buildSidebarItem(Icons.account_circle, 'Account', 1),
                  _buildSidebarItem(Icons.palette, 'Appearance', 2),
                  _buildSidebarItem(Icons.notifications, 'Notifications', 3),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mobile tabs
                  if (MediaQuery.of(context).size.width <= 600)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildTabButton(Icons.person, 'Profile', 0)),
                          Expanded(child: _buildTabButton(Icons.account_circle, 'Account', 1)),
                          Expanded(child: _buildTabButton(Icons.palette, 'Appearance', 2)),
                          Expanded(child: _buildTabButton(Icons.notifications, 'Notify', 3)),
                        ],
                      ),
                    ),
                  // Content based on selected section
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final isSelected = _selectedSection == index;
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingXS),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5))
            : null,
      ),
      child: ListTile(
        selected: isSelected,
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.accentColor : AppTheme.textSecondaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.accentColor : AppTheme.textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedSection = index;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTabButton(IconData icon, String title, int index) {
    final isSelected = _selectedSection == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSection = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.textColor : AppTheme.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.textColor : AppTheme.textSecondaryColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedSection) {
      case 0:
        return _buildPublicProfile();
      case 1:
        return _buildAccount();
      case 2:
        return _buildAppearance();
      case 3:
        return _buildNotifications();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPublicProfile() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Public profile',
                style: AppTheme.heading2.copyWith(fontSize: 26),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          _buildEnhancedTextField(
            controller: _nameController,
            label: 'Name',
            icon: Icons.person_outline,
            hint: 'Enter your name',
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildEnhancedTextField(
            controller: _emailController,
            label: 'Public email',
            icon: Icons.email_outlined,
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildEnhancedTextField(
            controller: _bioController,
            label: 'Bio',
            icon: Icons.description_outlined,
            hint: 'Tell us about yourself',
            maxLines: 4,
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildEnhancedDropdown(
            label: 'Pronouns',
            icon: Icons.people_outline,
            value: _pronouns,
            items: ['he/him', 'she/her'],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _pronouns = value;
                });
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildEnhancedTextField(
            controller: _urlController,
            label: 'URL',
            icon: Icons.link,
            hint: 'Enter your profile URL',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                backgroundColor: AppTheme.accentColor,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textColor,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.accentColor),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            prefixIcon: Icon(icon, color: AppTheme.textSecondaryColor),
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppTheme.spacingM),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            if (keyboardType == TextInputType.emailAddress && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.accentColor),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.textSecondaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppTheme.spacingM),
            ),
            dropdownColor: AppTheme.cardColor,
            style: AppTheme.bodyMedium,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildAccount() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_circle,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Text(
              'Account Settings',
              style: AppTheme.heading2.copyWith(fontSize: 26),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXL),
        _buildSettingsCard(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () {},
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildSettingsCard(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          onTap: () {},
          isDanger: true,
        ),
      ],
    );
  }

  Widget _buildAppearance() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.palette,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Text(
              'Appearance Settings',
              style: AppTheme.heading2.copyWith(fontSize: 26),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXL),
        _buildSwitchTile(
          icon: Icons.dark_mode,
          title: 'Dark Mode',
          subtitle: 'Switch between light and dark theme',
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotifications() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Text(
              'Notification Settings',
              style: AppTheme.heading2.copyWith(fontSize: 26),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXL),
        _buildSwitchTile(
          icon: Icons.email,
          title: 'Email Notifications',
          subtitle: 'Receive notifications via email',
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildSwitchTile(
          icon: Icons.sms,
          title: 'SMS Notifications',
          subtitle: 'Receive notifications via SMS',
          value: _smsNotifications,
          onChanged: (value) {
            setState(() {
              _smsNotifications = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: (isDanger ? AppTheme.errorColor : AppTheme.accentColor)
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDanger ? AppTheme.errorColor : AppTheme.accentColor,
          ),
        ),
        title: Text(title, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: AppTheme.bodySmall),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondaryColor,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentColor),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.accentColor.withValues(alpha: 0.5),
            activeThumbColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }
}
