import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onToggleBlock;
  final VoidCallback onTogglePremium;

  const UserTile({
    super.key,
    required this.user,
    required this.onToggleBlock,
    required this.onTogglePremium,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: user.isBlocked
              ? Colors.red.withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: _avatarColor(user.displayName),
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          decoration: user.isBlocked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFFF59E0B),
                            ),
                            SizedBox(width: 2),
                            Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (user.isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BLOCKED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'block') onToggleBlock();
              if (value == 'premium') onTogglePremium();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      user.isBlocked
                          ? Icons.lock_open_rounded
                          : Icons.block_rounded,
                      size: 18,
                      color: user.isBlocked ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(user.isBlocked ? 'Unblock' : 'Block'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'premium',
                child: Row(
                  children: [
                    Icon(
                      user.isPremium
                          ? Icons.star_border_rounded
                          : Icons.star_rounded,
                      size: 18,
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Text(user.isPremium ? 'Remove Premium' : 'Grant Premium'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }
}
