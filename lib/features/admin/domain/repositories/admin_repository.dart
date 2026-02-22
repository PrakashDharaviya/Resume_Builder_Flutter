import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/ats_config.dart';
import '../../domain/entities/resume_template.dart';
import '../../../auth/domain/entities/user.dart';

abstract class AdminRepository {
  // Dashboard
  Either<Failure, AdminStats> getAdminStats();

  // Templates
  Either<Failure, List<ResumeTemplate>> getAllTemplates();
  Either<Failure, ResumeTemplate> addTemplate(ResumeTemplate template);
  Either<Failure, ResumeTemplate> updateTemplate(ResumeTemplate template);
  Either<Failure, Unit> deleteTemplate(String id);

  // Users
  Either<Failure, List<User>> getAllUsers();
  Either<Failure, User> toggleBlockUser(String uid);
  Either<Failure, User> togglePremiumUser(String uid);

  // ATS Config
  Either<Failure, ATSConfig> getATSConfig();
  Either<Failure, ATSConfig> updateATSConfig(ATSConfig config);

  // Announcements
  Either<Failure, List<Announcement>> getAllAnnouncements();
  Either<Failure, Announcement> addAnnouncement(Announcement announcement);
  Either<Failure, Announcement> toggleAnnouncement(String id);
  Either<Failure, Unit> deleteAnnouncement(String id);
}
