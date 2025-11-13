import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PostWidget extends StatefulWidget {
  final String profileImage;
  final String userName;
  final String timeAgo;
  final String content;
  final String? postImage;
  final int likes;
  final int comments;
  final int reposts;

  const PostWidget({
    super.key,
    this.profileImage = 'assets/images/profilepostpic.png',
    this.userName = 'Real Madrid C.F.',
    this.timeAgo = '2h',
    this.content =
        '💪 Final session ahead of Rayo clash!\n🔥 ¡Último entrenamiento antes del partido contra el Rayo!\n#RMCity #RayoRealMadrid',
    this.postImage = 'assets/images/post.png',
    this.likes = 0,
    this.comments = 0,
    this.reposts = 0,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isReposted = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 1),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Header
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.cardColor,
                          backgroundImage: AssetImage(widget.profileImage),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.userName,
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingXS),
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: AppTheme.accentColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.timeAgo,
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: AppTheme.textSecondaryColor,
                        iconSize: 20,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  // Post Content
                  Text(
                    widget.content,
                    style: AppTheme.bodyMedium.copyWith(
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  if (widget.postImage != null) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.postImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppTheme.textSecondaryColor,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingM),
                  // Post Stats
                  if (widget.likes > 0 || widget.comments > 0 || widget.reposts > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: Row(
                        children: [
                          if (widget.likes > 0) ...[
                            _buildStatChip(
                              Icons.favorite,
                              widget.likes.toString(),
                              AppTheme.errorColor,
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                          ],
                          if (widget.comments > 0) ...[
                            _buildStatChip(
                              Icons.comment,
                              widget.comments.toString(),
                              AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                          ],
                          if (widget.reposts > 0)
                            _buildStatChip(
                              Icons.repeat,
                              widget.reposts.toString(),
                              AppTheme.successColor,
                            ),
                        ],
                      ),
                    ),
                  // Divider
                  Divider(
                    color: AppTheme.borderColor.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  // Post Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                        label: 'Like',
                        count: widget.likes,
                        isActive: _isLiked,
                        activeColor: AppTheme.errorColor,
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                          _animationController.forward().then((_) {
                            _animationController.reverse();
                          });
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.comment_outlined,
                        label: 'Comment',
                        count: widget.comments,
                        onTap: () {},
                      ),
                      _buildActionButton(
                        icon: _isReposted ? Icons.repeat : Icons.repeat_outlined,
                        label: 'Repost',
                        count: widget.reposts,
                        isActive: _isReposted,
                        activeColor: AppTheme.successColor,
                        onTap: () {
                          setState(() {
                            _isReposted = !_isReposted;
                          });
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppTheme.spacingXS),
        Text(
          count,
          style: AppTheme.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    int? count,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final color = isActive
        ? (activeColor ?? AppTheme.accentColor)
        : AppTheme.textSecondaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingS,
          vertical: AppTheme.spacingXS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: color,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
