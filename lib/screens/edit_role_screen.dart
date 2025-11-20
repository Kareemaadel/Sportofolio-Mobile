import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';

class EditRoleScreen extends StatefulWidget {
  final String currentRole;

  const EditRoleScreen({super.key, required this.currentRole});

  @override
  State<EditRoleScreen> createState() => _EditRoleScreenState();
}

class _EditRoleScreenState extends State<EditRoleScreen> {
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.currentRole);
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _saveRole() async {
    await DataService.setRole(_roleController.text);
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Role',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveRole,
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _roleController,
              style: TextStyle(color: textColor, fontSize: 16),
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Enter your role',
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: textColor.withOpacity(0.3)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: textColor.withOpacity(0.3)),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Your role or position (e.g., Goalkeeper, Midfielder)',
              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
