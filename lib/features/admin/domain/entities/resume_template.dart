import 'package:equatable/equatable.dart';

class ResumeTemplate extends Equatable {
  final String id;
  final String name;
  final bool isActive;
  final bool isPremium;
  final String templateType; // professional, modern, minimal, creative, classic
  final String layoutJson;
  final String previewImage;
  final String assetType; // image or pdf
  final String assetName;
  final String assetDataBase64; // Base64-encoded file data
  final List<String> tags; // e.g. ['BCA', 'MCA', 'IT', 'fresher']
  final String category; // e.g. 'engineering', 'commerce', 'arts', 'medical'
  final String targetProfession; // e.g. 'Software Developer', 'Accountant'
  final DateTime createdAt;

  const ResumeTemplate({
    required this.id,
    required this.name,
    this.isActive = true,
    this.isPremium = false,
    this.templateType = 'professional',
    this.layoutJson = '{}',
    this.previewImage = '',
    this.assetType = 'image',
    this.assetName = '',
    this.assetDataBase64 = '',
    this.tags = const [],
    this.category = '',
    this.targetProfession = '',
    required this.createdAt,
  });

  static const List<String> templateTypes = [
    'professional',
    'modern',
    'minimal',
    'creative',
    'classic',
  ];

  static const List<String> categoryOptions = [
    'engineering',
    'commerce',
    'arts',
    'medical',
    'management',
    'science',
    'law',
    'design',
    'education',
    'general',
  ];

  static String categoryLabel(String category) {
    switch (category) {
      case 'engineering':
        return 'Engineering & IT';
      case 'commerce':
        return 'Commerce & Finance';
      case 'arts':
        return 'Arts & Humanities';
      case 'medical':
        return 'Medical & Health';
      case 'management':
        return 'Management & MBA';
      case 'science':
        return 'Science & Research';
      case 'law':
        return 'Law & Legal';
      case 'design':
        return 'Design & Creative';
      case 'education':
        return 'Education & Teaching';
      case 'general':
        return 'General Purpose';
      default:
        return 'General Purpose';
    }
  }

  static String templateTypeLabel(String type) {
    switch (type) {
      case 'professional':
        return 'Professional';
      case 'modern':
        return 'Modern';
      case 'minimal':
        return 'Minimal';
      case 'creative':
        return 'Creative';
      case 'classic':
        return 'Classic';
      default:
        return 'Professional';
    }
  }

  ResumeTemplate copyWith({
    String? id,
    String? name,
    bool? isActive,
    bool? isPremium,
    String? templateType,
    String? layoutJson,
    String? previewImage,
    String? assetType,
    String? assetName,
    String? assetDataBase64,
    List<String>? tags,
    String? category,
    String? targetProfession,
    DateTime? createdAt,
  }) {
    return ResumeTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      templateType: templateType ?? this.templateType,
      layoutJson: layoutJson ?? this.layoutJson,
      previewImage: previewImage ?? this.previewImage,
      assetType: assetType ?? this.assetType,
      assetName: assetName ?? this.assetName,
      assetDataBase64: assetDataBase64 ?? this.assetDataBase64,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      targetProfession: targetProfession ?? this.targetProfession,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    isActive,
    isPremium,
    templateType,
    layoutJson,
    previewImage,
    assetType,
    assetName,
    assetDataBase64,
    tags,
    category,
    targetProfession,
    createdAt,
  ];
}
