import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/ats_config.dart';
import '../../domain/entities/resume_template.dart';
import '../../../auth/domain/entities/user.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

// ========== General States ==========
class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminError extends AdminState {
  final String message;

  const AdminError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// ========== Dashboard States ==========
class AdminDashboardLoaded extends AdminState {
  final AdminStats stats;

  const AdminDashboardLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

// ========== Template States ==========
class TemplatesLoaded extends AdminState {
  final List<ResumeTemplate> templates;

  const TemplatesLoaded({required this.templates});

  @override
  List<Object?> get props => [templates];
}

// ========== User States ==========
class UsersLoaded extends AdminState {
  final List<User> users;
  final List<User>? filteredUsers;

  const UsersLoaded({required this.users, this.filteredUsers});

  List<User> get displayUsers => filteredUsers ?? users;

  @override
  List<Object?> get props => [users, filteredUsers];
}

// ========== ATS Config States ==========
class ATSConfigLoaded extends AdminState {
  final ATSConfig config;

  const ATSConfigLoaded({required this.config});

  @override
  List<Object?> get props => [config];
}

// ========== Announcement States ==========
class AnnouncementsLoaded extends AdminState {
  final List<Announcement> announcements;

  const AnnouncementsLoaded({required this.announcements});

  @override
  List<Object?> get props => [announcements];
}
