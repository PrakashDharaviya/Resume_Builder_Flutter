import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsers;
  final int totalResumes;
  final int premiumUsers;
  final double avgAtsScore;
  final String mostUsedTemplate;
  final int activeTemplates;
  final int blockedUsers;
  final int todaySignups;

  const AdminStats({
    this.totalUsers = 0,
    this.totalResumes = 0,
    this.premiumUsers = 0,
    this.avgAtsScore = 0,
    this.mostUsedTemplate = 'Classic',
    this.activeTemplates = 0,
    this.blockedUsers = 0,
    this.todaySignups = 0,
  });

  AdminStats copyWith({
    int? totalUsers,
    int? totalResumes,
    int? premiumUsers,
    double? avgAtsScore,
    String? mostUsedTemplate,
    int? activeTemplates,
    int? blockedUsers,
    int? todaySignups,
  }) {
    return AdminStats(
      totalUsers: totalUsers ?? this.totalUsers,
      totalResumes: totalResumes ?? this.totalResumes,
      premiumUsers: premiumUsers ?? this.premiumUsers,
      avgAtsScore: avgAtsScore ?? this.avgAtsScore,
      mostUsedTemplate: mostUsedTemplate ?? this.mostUsedTemplate,
      activeTemplates: activeTemplates ?? this.activeTemplates,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      todaySignups: todaySignups ?? this.todaySignups,
    );
  }

  @override
  List<Object?> get props => [
    totalUsers,
    totalResumes,
    premiumUsers,
    avgAtsScore,
    mostUsedTemplate,
    activeTemplates,
    blockedUsers,
    todaySignups,
  ];
}
