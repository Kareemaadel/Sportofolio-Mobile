import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const SearchBarWidget({
    super.key,
    this.placeholder = 'Search...',
    this.onChanged,
    this.onTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: _isFocused
              ? LinearGradient(
                  colors: [
                    AppTheme.cardColor,
                    AppTheme.cardColor.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: _isFocused ? null : AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isFocused
                ? AppTheme.accentColor
                : AppTheme.borderColor,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused ? AppTheme.cardShadow : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: _isFocused
                  ? AppTheme.accentColor
                  : AppTheme.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: TextField(
                onChanged: widget.onChanged,
                onTap: () {
                  setState(() {
                    _isFocused = true;
                  });
                },
                onTapOutside: (_) {
                  setState(() {
                    _isFocused = false;
                  });
                },
                style: AppTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

