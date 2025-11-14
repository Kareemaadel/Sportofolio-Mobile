import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

class EditUsernameScreen extends StatefulWidget {
  final String currentUsername;

  const EditUsernameScreen({super.key, required this.currentUsername});

  @override
  State<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  late TextEditingController _usernameController;
  int _maxLength = 30;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    if (_usernameController.text.trim().isNotEmpty) {
      await DataService.setEmail(_usernameController.text.trim());
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textColor, fontSize: 16),
          ),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: _saveUsername,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFFFF3B5C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
            const Text(
              'Username',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your username can only be changed once every 7 days.',
              style: TextStyle(color: Color(0xFF8A8B8F), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _usernameController,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
                maxLength: _maxLength,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  counterText: '',
                  suffixIcon: _usernameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Color(0xFF8A8B8F),
                          ),
                          onPressed: () {
                            setState(() {
                              _usernameController.clear();
                            });
                          },
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
                '${_usernameController.text.length}/$_maxLength',
                style: const TextStyle(color: Color(0xFF8A8B8F), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
