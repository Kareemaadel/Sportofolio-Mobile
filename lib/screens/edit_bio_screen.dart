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
            onPressed: _saveBio,
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
              'Bio',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _bioController,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
                maxLength: _maxLength,
                maxLines: 4,
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
                              icon: const Icon(
                                Icons.cancel,
                                color: Color(0xFF8A8B8F),
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
                style: const TextStyle(color: Color(0xFF8A8B8F), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
