import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../domain/entities/announcement.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAnnouncements());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              final isDarkMode =
                  themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return IconButton(
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  themeNotifier.value = isDarkMode
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAnnouncementForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Announcement'),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            context.read<AdminBloc>().add(const LoadAnnouncements());
          }
        },
        buildWhen: (_, current) =>
            current is AnnouncementsLoaded ||
            current is AdminLoading ||
            current is AdminError,
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AdminBloc>().add(
                      const LoadAnnouncements(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AnnouncementsLoaded) {
            if (state.announcements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: isDark
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No announcements yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first announcement',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth >= 1024
                    ? 900.0
                    : (constraints.maxWidth >= 640 ? 680.0 : double.infinity);

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                      itemCount: state.announcements.length,
                      itemBuilder: (context, index) {
                        final item = state.announcements[index];
                        return _AnnouncementCard(
                          announcement: item,
                          isDark: isDark,
                          onToggle: () {
                            context.read<AdminBloc>().add(
                              ToggleAnnouncement(announcementId: item.id),
                            );
                          },
                          onDelete: () => _showDeleteConfirm(context, item),
                          onEdit: () => _showAnnouncementForm(
                            context,
                            announcement: item,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAnnouncementForm(
    BuildContext context, {
    Announcement? announcement,
  }) {
    final isEdit = announcement != null;
    final titleController = TextEditingController(
      text: announcement?.title ?? '',
    );
    final messageController = TextEditingController(
      text: announcement?.message ?? '',
    );
    bool isActive = announcement?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF4B5563)
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isEdit ? 'Edit Announcement' : 'New Announcement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Message',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          onChanged: (v) => setModalState(() => isActive = v),
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final message = messageController.text.trim();
                          if (title.isEmpty || message.isEmpty) return;
                          Navigator.pop(ctx);
                          final newAnnouncement = Announcement(
                            id: isEdit
                                ? announcement!.id
                                : DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                            title: title,
                            message: message,
                            createdAt: isEdit
                                ? announcement!.createdAt
                                : DateTime.now(),
                            isActive: isActive,
                          );
                          context.read<AdminBloc>().add(
                            AddAnnouncement(announcement: newAnnouncement),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Update' : 'Publish',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, Announcement item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Announcement',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(
                DeleteAnnouncement(announcementId: item.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AnnouncementCard({
    required this.announcement,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM dd, yyyy').format(announcement.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: announcement.isActive
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  announcement.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: announcement.isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            announcement.message,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 14,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: announcement.isActive,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
