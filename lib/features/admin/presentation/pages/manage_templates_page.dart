import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../domain/entities/resume_template.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/template_tile.dart';

class ManageTemplatesPage extends StatefulWidget {
  const ManageTemplatesPage({super.key});

  @override
  State<ManageTemplatesPage> createState() => _ManageTemplatesPageState();
}

class _ManageTemplatesPageState extends State<ManageTemplatesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadTemplates());
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
          'Manage Templates',
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
        onPressed: () => _showTemplateForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Template'),
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
          }
        },
        buildWhen: (_, current) =>
            current is TemplatesLoaded ||
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
                    onPressed: () =>
                        context.read<AdminBloc>().add(const LoadTemplates()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TemplatesLoaded) {
            if (state.templates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.style_outlined,
                      size: 56,
                      color: isDark
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No templates yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap + to add your first template'),
                  ],
                ),
              );
            }

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                  itemCount: state.templates.length,
                  itemBuilder: (context, index) {
                    final template = state.templates[index];
                    return TemplateTile(
                      template: template,
                      onEdit: () =>
                          _showTemplateForm(context, template: template),
                      onDelete: () {
                        _showDeleteConfirm(context, template);
                      },
                      onToggleActive: (active) {
                        context.read<AdminBloc>().add(
                          UpdateTemplate(
                            template: template.copyWith(isActive: active),
                          ),
                        );
                      },
                    ); // closes TemplateTile
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showTemplateForm(BuildContext context, {ResumeTemplate? template}) {
    final isEdit = template != null;
    final nameController = TextEditingController(text: template?.name ?? '');
    bool isPremium = template?.isPremium ?? false;
    bool isActive = template?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
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
                      isEdit ? 'Edit Template' : 'Add Template',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Template Name',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Premium Template'),
                      subtitle: const Text('Only available to premium users'),
                      value: isPremium,
                      onChanged: (v) => setModalState(() => isPremium = v),
                      activeColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: const Text('Visible to users'),
                      value: isActive,
                      onChanged: (v) => setModalState(() => isActive = v),
                      activeColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;

                          if (isEdit) {
                            context.read<AdminBloc>().add(
                              UpdateTemplate(
                                template: template.copyWith(
                                  name: nameController.text.trim(),
                                  isPremium: isPremium,
                                  isActive: isActive,
                                ),
                              ),
                            );
                          } else {
                            context.read<AdminBloc>().add(
                              AddTemplate(
                                template: ResumeTemplate(
                                  id: '',
                                  name: nameController.text.trim(),
                                  isActive: isActive,
                                  isPremium: isPremium,
                                  layoutJson: '{}',
                                  previewImage: '',
                                  createdAt: DateTime.now(),
                                ),
                              ),
                            );
                          }
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Save Changes' : 'Add Template',
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

  void _showDeleteConfirm(BuildContext context, ResumeTemplate template) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Template',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
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
                DeleteTemplate(templateId: template.id),
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
