import 'package:equatable/equatable.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';

// ========== Admin Dashboard Events ==========
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminDashboard extends AdminEvent {
  const LoadAdminDashboard();
}

// ========== Template Events ==========
class LoadTemplates extends AdminEvent {
  const LoadTemplates();
}

class FetchTemplates extends AdminEvent {
  const FetchTemplates();
}

class AddTemplate extends AdminEvent {
  final ResumeTemplate template;

  const AddTemplate({required this.template});

  @override
  List<Object?> get props => [template];
}

class UpdateTemplate extends AdminEvent {
  final ResumeTemplate template;

  const UpdateTemplate({required this.template});

  @override
  List<Object?> get props => [template];
}

class DeleteTemplate extends AdminEvent {
  final String templateId;

  const DeleteTemplate({required this.templateId});

  @override
  List<Object?> get props => [templateId];
}

// ========== User Management Events ==========
class LoadUsers extends AdminEvent {
  const LoadUsers();
}

class FetchUsers extends AdminEvent {
  const FetchUsers();
}

class ToggleBlockUser extends AdminEvent {
  final String uid;

  const ToggleBlockUser({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class TogglePremiumUser extends AdminEvent {
  final String uid;

  const TogglePremiumUser({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class SearchUsers extends AdminEvent {
  final String query;

  const SearchUsers({required this.query});

  @override
  List<Object?> get props => [query];
}

// ========== ATS Config Events ==========
class LoadATSConfig extends AdminEvent {
  const LoadATSConfig();
}

class UpdateATSConfig extends AdminEvent {
  final ATSConfig config;

  const UpdateATSConfig({required this.config});

  @override
  List<Object?> get props => [config];
}

// ========== Announcement Events ==========
class LoadAnnouncements extends AdminEvent {
  const LoadAnnouncements();
}

class AddAnnouncement extends AdminEvent {
  final Announcement announcement;

  const AddAnnouncement({required this.announcement});

  @override
  List<Object?> get props => [announcement];
}

class UpdateAnnouncement extends AdminEvent {
  final Announcement announcement;

  const UpdateAnnouncement({required this.announcement});

  @override
  List<Object?> get props => [announcement];
}

class ToggleAnnouncement extends AdminEvent {
  final String announcementId;

  const ToggleAnnouncement({required this.announcementId});

  @override
  List<Object?> get props => [announcementId];
}

class DeleteAnnouncement extends AdminEvent {
  final String announcementId;

  const DeleteAnnouncement({required this.announcementId});

  @override
  List<Object?> get props => [announcementId];
}

// ========== Notification Events ==========
class LoadNotifications extends AdminEvent {
  const LoadNotifications();
}

class SendBroadcastNotification extends AdminEvent {
  final String title;
  final String body;

  const SendBroadcastNotification({required this.title, required this.body});

  @override
  List<Object?> get props => [title, body];
}

class DeleteNotification extends AdminEvent {
  final String notificationId;

  const DeleteNotification({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}
