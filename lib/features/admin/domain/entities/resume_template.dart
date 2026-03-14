import 'package:equatable/equatable.dart';

class ResumeTemplate extends Equatable {
  final String id;
  final String name;
  final bool isActive;
  final bool isPremium;
  final String templateType; // professional, modern, minimal, creative, classic
  final String layoutJson;
  final String previewImage;
  final DateTime createdAt;

  const ResumeTemplate({
    required this.id,
    required this.name,
    this.isActive = true,
    this.isPremium = false,
    this.templateType = 'professional',
    this.layoutJson = '{}',
    this.previewImage = '',
    required this.createdAt,
  });

  static const List<String> templateTypes = [
    'professional',
    'modern',
    'minimal',
    'creative',
    'classic',
  ];

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
    createdAt,
  ];
}
