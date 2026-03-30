import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/admin/domain/entities/admin_stats.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/app_notification.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';

abstract class AdminRepository {
  // Dashboard
  Future<Either<Failure, AdminStats>> getAdminStats();

  // Templates
  Future<Either<Failure, List<ResumeTemplate>>> getAllTemplates();
  Future<Either<Failure, ResumeTemplate>> addTemplate(ResumeTemplate template);
  Future<Either<Failure, ResumeTemplate>> updateTemplate(
    ResumeTemplate template,
  );
  Future<Either<Failure, Unit>> deleteTemplate(String id);

  // Users
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, User>> toggleBlockUser(String uid);
  Future<Either<Failure, User>> togglePremiumUser(String uid);

  // ATS Config
  Future<Either<Failure, ATSConfig>> getATSConfig();
  Future<Either<Failure, ATSConfig>> updateATSConfig(ATSConfig config);

  // Announcements
  Future<Either<Failure, List<Announcement>>> getAllAnnouncements();
  Future<Either<Failure, Announcement>> addAnnouncement(
    Announcement announcement,
  );
  Future<Either<Failure, Announcement>> updateAnnouncement(
    Announcement announcement,
  );
  Future<Either<Failure, Announcement>> toggleAnnouncement(String id);
  Future<Either<Failure, Unit>> deleteAnnouncement(String id);

  // Notifications
  Future<Either<Failure, List<AppNotification>>> getAllNotifications();
  Future<Either<Failure, AppNotification>> addNotification(
    AppNotification notification,
  );
  Future<Either<Failure, Unit>> deleteNotification(String id);
}
