import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/ats_config.dart';
import '../../domain/entities/resume_template.dart';
import '../../../auth/domain/entities/user.dart';

abstract class AdminRepository {
  // Dashboard
  Future<Either<Failure, AdminStats>> getAdminStats();

  // Templates
  Future<Either<Failure, List<ResumeTemplate>>> getAllTemplates();
  Future<Either<Failure, ResumeTemplate>> addTemplate(ResumeTemplate template);
  Future<Either<Failure, ResumeTemplate>> updateTemplate(ResumeTemplate template);
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
  Future<Either<Failure, Announcement>> addAnnouncement(Announcement announcement);
  Future<Either<Failure, Announcement>> toggleAnnouncement(String id);
  Future<Either<Failure, Unit>> deleteAnnouncement(String id);
}
