import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TrialsScreen extends StatelessWidget {
  const TrialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;
    final textColor = isDark ? AppTheme.textColor : AppTheme.textColorLight;
    final textSecondaryColor = isDark
        ? AppTheme.textSecondaryColor
        : AppTheme.textSecondaryColorLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 80,
                  color: textSecondaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Trials Application',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This feature will be available soon',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay tuned for updates!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textSecondaryColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
