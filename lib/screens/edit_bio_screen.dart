import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

class EditBioScreen extends StatefulWidget {
  final String currentBio;

  const EditBioScreen({super.key, required this.currentBio});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  late TextEditingController _bioController;
  int _maxLength = 80;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveBio() async {
    await DataService.setBio(_bioController.text.trim());
    if (mounted) {
      Navigator.pop(context, true);
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
    final secondaryTextColor = isDark
        ? const Color(0xFF8A8B8F)
        : AppTheme.textSecondaryColorLight;
    final inputBgColor = isDark
        ? const Color(0xFF1F1F1F)
        : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saveBio,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bio',
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Write a short description about yourself',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _bioController,
                style: TextStyle(color: textColor, fontSize: 16),
                maxLength: _maxLength,
                maxLines: 6,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterText: '',
                  suffixIcon: _bioController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8, right: 8),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: secondaryTextColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _bioController.clear();
                                });
                              },
                            ),
                          ),
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_bioController.text.length}/$_maxLength',
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
