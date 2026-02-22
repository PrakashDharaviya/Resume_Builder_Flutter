import 'package:equatable/equatable.dart';

class ResumeTemplate extends Equatable {
  final String id;
  final String name;
  final bool isActive;
  final bool isPremium;
  final String layoutJson;
  final String previewImage;
  final DateTime createdAt;

  const ResumeTemplate({
    required this.id,
    required this.name,
    this.isActive = true,
    this.isPremium = false,
    this.layoutJson = '{}',
    this.previewImage = '',
    required this.createdAt,
  });

  ResumeTemplate copyWith({
    String? id,
    String? name,
    bool? isActive,
    bool? isPremium,
    String? layoutJson,
    String? previewImage,
    DateTime? createdAt,
  }) {
    return ResumeTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
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
    layoutJson,
    previewImage,
    createdAt,
  ];
}
