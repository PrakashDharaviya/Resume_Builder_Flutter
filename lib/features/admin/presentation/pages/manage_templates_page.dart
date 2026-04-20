import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:resumebuilder/admin/presentation/widgets/admin_drawer.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/utils/app_preferences.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:resumebuilder/features/admin/presentation/bloc/admin_event.dart';
import 'package:resumebuilder/features/admin/presentation/bloc/admin_state.dart';
import 'package:resumebuilder/features/admin/presentation/widgets/template_tile.dart';

class ManageTemplatesPage extends StatefulWidget {
  const ManageTemplatesPage({super.key});

  @override
  State<ManageTemplatesPage> createState() => ManageTemplatesPageState();
}

class ManageTemplatesPageState extends State<ManageTemplatesPage> {
  static const int _maxInlineFileBytes = 700 * 1024;
  bool _savingTemplate = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadTemplates());
  }

  Future<_TemplateAssetPick?> _pickTemplateAsset() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to read selected file. Try a smaller PDF/image file.',
            ),
          ),
        );
      }
      return null;
    }

    final ext = (file.extension ?? '').toLowerCase();
    final type = ext == 'pdf' ? 'pdf' : 'image';
    final optimizedBytes = await _optimizeImageBytes(
      bytes: file.bytes!,
      fileType: type,
      extension: ext,
    );

    if (optimizedBytes.lengthInBytes > _maxInlineFileBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File is too large after compression. Keep it under 700 KB.',
            ),
          ),
        );
      }
      return null;
    }

    return _TemplateAssetPick(
      name: file.name,
      type: type,
      bytes: optimizedBytes,
      path: file.path,
    );
  }

  Future<Uint8List> _optimizeImageBytes({
    required Uint8List bytes,
    required String fileType,
    required String extension,
  }) async {
    if (fileType != 'image') return bytes;

    if (bytes.lengthInBytes <= _maxInlineFileBytes) {
      return bytes;
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }

    img.Image current = decoded;

    List<int> encode(img.Image image, int quality) {
      if (extension == 'png') {
        return img.encodePng(image, level: 9);
      }
      return img.encodeJpg(image, quality: quality);
    }

    for (final quality in <int>[85, 75, 65, 55, 45]) {
      final encoded = encode(current, quality);
      if (encoded.length <= _maxInlineFileBytes) {
        return Uint8List.fromList(encoded);
      }
    }

    for (final maxWidth in <int>[1600, 1280, 1024, 900, 768]) {
      if (current.width > maxWidth) {
        current = img.copyResize(current, width: maxWidth);
      }
      for (final quality in <int>[75, 60, 50, 40]) {
        final encoded = encode(current, quality);
        if (encoded.length <= _maxInlineFileBytes) {
          return Uint8List.fromList(encoded);
        }
      }
    }

    return Uint8List.fromList(encode(current, 40));
  }

  Future<String> _encodeTemplateAssetToBase64(_TemplateAssetPick asset) async {
    if (asset.bytes == null) {
      throw Exception('Selected file could not be read. Please try again.');
    }
    if (asset.bytes!.lengthInBytes > _maxInlineFileBytes) {
      throw Exception(
        'File is too large for free Firestore storage. Keep it under 700 KB.',
      );
    }
    return base64Encode(asset.bytes!);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
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
      drawer: const AdminDrawer(currentRoute: AppRoutes.manageTemplates),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTemplateForm(context),
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
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 400;
                    final hPad = isNarrow ? 12.0 : 20.0;
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                      itemCount: state.templates.length,
                      itemBuilder: (context, index) {
                        final template = state.templates[index];
                        return TemplateTile(
                          template: template,
                          onPreview: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.templatePreview,
                              arguments: template,
                            );
                          },
                          onEdit: () =>
                              showTemplateForm(context, template: template),
                          onDelete: () {
                            showDeleteConfirm(context, template);
                          },
                          onToggleActive: (active) {
                            context.read<AdminBloc>().add(
                              UpdateTemplate(
                                template: template.copyWith(isActive: active),
                              ),
                            );
                          },
                        );
                      },
                    );
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

  void showTemplateForm(BuildContext context, {ResumeTemplate? template}) {
    final adminBloc = context.read<AdminBloc>();
    final isEdit = template != null;
    final nameController = TextEditingController(text: template?.name ?? '');
    bool isPremium = template?.isPremium ?? false;
    bool isActive = template?.isActive ?? true;
    String selectedType = template?.templateType ?? 'professional';
    final String currentAssetUrl = template?.previewImage ?? '';
    final String currentAssetType = template?.assetType ?? 'image';
    final String currentAssetName = template?.assetName ?? '';
    String currentAssetBase64 = template?.assetDataBase64 ?? '';
    _TemplateAssetPick? selectedAsset;

    showModalBottomSheet<void>(
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
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.9,
                  ),
                  child: SingleChildScrollView(
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
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
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

                          // Template Type Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: selectedType,
                            decoration: InputDecoration(
                              labelText: 'Template Type',
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: ResumeTemplate.templateTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(
                                      typeIcon(type),
                                      size: 18,
                                      color: typeColor(type),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      ResumeTemplate.templateTypeLabel(type),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setModalState(() => selectedType = value);
                              }
                            },
                          ),

                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAsset != null
                                      ? 'Selected: ${selectedAsset!.name}'
                                      : (currentAssetName.isNotEmpty
                                            ? 'Current: $currentAssetName'
                                            : 'No template asset selected'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFFD1D5DB)
                                        : const Color(0xFF374151),
                                  ),
                                ),
                                if (currentAssetUrl.isNotEmpty ||
                                    selectedAsset != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Asset Type: ${selectedAsset?.type ?? currentAssetType}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                                if (selectedAsset != null ||
                                    currentAssetBase64.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _assetPreviewBox(
                                    isDark: isDark,
                                    bytes: selectedAsset?.bytes,
                                    type:
                                        selectedAsset?.type ?? currentAssetType,
                                    base64Data: currentAssetBase64,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final asset = await _pickTemplateAsset();
                                      if (asset == null) return;
                                      setModalState(
                                        () => selectedAsset = asset,
                                      );
                                    },
                                    icon: const Icon(Icons.upload_file_rounded),
                                    label: Text(
                                      isEdit
                                          ? 'Replace Template Asset (PDF/Image)'
                                          : 'Upload Template Asset (PDF/Image)',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: const Text('Premium Template'),
                            subtitle: const Text(
                              'Only available to premium users',
                            ),
                            value: isPremium,
                            onChanged: (v) =>
                                setModalState(() => isPremium = v),
                            activeTrackColor: const Color(0xFFF59E0B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('Active'),
                            subtitle: const Text('Visible to users'),
                            value: isActive,
                            onChanged: (v) => setModalState(() => isActive = v),
                            activeTrackColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _savingTemplate
                                  ? null
                                  : () async {
                                      if (nameController.text.trim().isEmpty) {
                                        return;
                                      }

                                      try {
                                        setState(() => _savingTemplate = true);

                                        final previewImage = currentAssetUrl;
                                        var assetType = currentAssetType;
                                        var assetName = currentAssetName;
                                        var assetDataBase64 = '';

                                        if (selectedAsset != null) {
                                          assetDataBase64 =
                                              await _encodeTemplateAssetToBase64(
                                                selectedAsset!,
                                              );
                                          assetType = selectedAsset!.type;
                                          assetName = selectedAsset!.name;
                                          currentAssetBase64 = assetDataBase64;
                                        }

                                        if (!ctx.mounted) return;

                                        if (isEdit) {
                                          adminBloc.add(
                                            UpdateTemplate(
                                              template: template.copyWith(
                                                name: nameController.text
                                                    .trim(),
                                                isPremium: isPremium,
                                                isActive: isActive,
                                                templateType: selectedType,
                                                previewImage: previewImage,
                                                assetType: assetType,
                                                assetName: assetName,
                                                assetDataBase64:
                                                    assetDataBase64.isNotEmpty
                                                    ? assetDataBase64
                                                    : null,
                                              ),
                                            ),
                                          );
                                        } else {
                                          adminBloc.add(
                                            AddTemplate(
                                              template: ResumeTemplate(
                                                id: '',
                                                name: nameController.text
                                                    .trim(),
                                                isActive: isActive,
                                                isPremium: isPremium,
                                                templateType: selectedType,
                                                layoutJson: '{}',
                                                previewImage: previewImage,
                                                assetType: assetType,
                                                assetName: assetName,
                                                assetDataBase64:
                                                    assetDataBase64,
                                                createdAt: DateTime.now(),
                                              ),
                                            ),
                                          );
                                        }

                                        if (!ctx.mounted) return;
                                        Navigator.pop(ctx);
                                      } catch (e) {
                                        if (!ctx.mounted) return;
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to save template: $e',
                                            ),
                                          ),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(
                                            () => _savingTemplate = false,
                                          );
                                        }
                                      }
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showDeleteConfirm(BuildContext context, ResumeTemplate template) {
    showDialog<void>(
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

  IconData typeIcon(String type) {
    switch (type) {
      case 'professional':
        return Icons.business_center_rounded;
      case 'modern':
        return Icons.auto_awesome_rounded;
      case 'minimal':
        return Icons.minimize_rounded;
      case 'creative':
        return Icons.color_lens_rounded;
      case 'classic':
        return Icons.article_rounded;
      default:
        return Icons.article_outlined;
    }
  }

  Color typeColor(String type) {
    switch (type) {
      case 'professional':
        return const Color(0xFF2B6CB0);
      case 'modern':
        return const Color(0xFF38BDF8);
      case 'minimal':
        return const Color(0xFF6B7280);
      case 'creative':
        return const Color(0xFF8B5CF6);
      case 'classic':
        return const Color(0xFF1F2937);
      default:
        return const Color(0xFF10B981);
    }
  }

  Widget _assetPreviewBox({
    required bool isDark,
    required Uint8List? bytes,
    required String type,
    required String base64Data,
  }) {
    if (type == 'image') {
      Uint8List? imageBytes = bytes;
      if (imageBytes == null && base64Data.isNotEmpty) {
        try {
          imageBytes = base64Decode(base64Data);
        } catch (_) {
          imageBytes = null;
        }
      }

      if (imageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            imageBytes,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stackTrace) =>
                _pdfOrFallbackPreview(isDark, type),
          ),
        );
      }
    }

    return _pdfOrFallbackPreview(isDark, type);
  }

  Widget _pdfOrFallbackPreview(bool isDark, String type) {
    final isPdf = type == 'pdf';
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              size: 34,
              color: isPdf ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9),
            ),
            const SizedBox(height: 6),
            Text(
              isPdf ? 'PDF uploaded' : 'Image preview unavailable',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateAssetPick {
  final String name;
  final String type;
  final Uint8List? bytes;
  final String? path;

  const _TemplateAssetPick({
    required this.name,
    required this.type,
    this.bytes,
    this.path,
  });
}
