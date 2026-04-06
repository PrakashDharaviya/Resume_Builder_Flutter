import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:resumebuilder/features/admin/domain/entities/admin_stats.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/app_notification.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/admin/domain/repositories/admin_repository.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource dataSource;

  AdminRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, AdminStats>> getAdminStats() async {
    try {
      return Right(await dataSource.getAdminStats());
    } catch (e) {
      return const Left(ServerFailure('Failed to load admin stats'));
    }
  }

  @override
  Future<Either<Failure, List<ResumeTemplate>>> getAllTemplates() async {
    try {
      return Right(await dataSource.getAllTemplates());
    } catch (e) {
      return const Left(ServerFailure('Failed to load templates'));
    }
  }

  @override
  Future<Either<Failure, ResumeTemplate>> addTemplate(
    ResumeTemplate template,
  ) async {
    try {
      return Right(await dataSource.addTemplate(template));
    } catch (e) {
      return const Left(ServerFailure('Failed to add template'));
    }
  }

  @override
  Future<Either<Failure, ResumeTemplate>> updateTemplate(
    ResumeTemplate template,
  ) async {
    try {
      return Right(await dataSource.updateTemplate(template));
    } catch (e) {
      return const Left(ServerFailure('Failed to update template'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTemplate(String id) async {
    try {
      await dataSource.deleteTemplate(id);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete template'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      return Right(await dataSource.getAllUsers());
    } catch (e) {
      return const Left(ServerFailure('Failed to load users'));
    }
  }

  @override
  Future<Either<Failure, User>> toggleBlockUser(String uid) async {
    try {
      return Right(await dataSource.toggleBlockUser(uid));
    } catch (e) {
      return const Left(ServerFailure('Failed to toggle block status'));
    }
  }

  @override
  Future<Either<Failure, User>> togglePremiumUser(String uid) async {
    try {
      return Right(await dataSource.togglePremiumUser(uid));
    } catch (e) {
      return const Left(ServerFailure('Failed to toggle premium status'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String uid) async {
    try {
      await dataSource.deleteUser(uid);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete user'));
    }
  }

  @override
  Future<Either<Failure, ATSConfig>> getATSConfig() async {
    try {
      return Right(await dataSource.getATSConfig());
    } catch (e) {
      return const Left(ServerFailure('Failed to load ATS config'));
    }
  }

  @override
  Future<Either<Failure, ATSConfig>> updateATSConfig(ATSConfig config) async {
    try {
      return Right(await dataSource.updateATSConfig(config));
    } catch (e) {
      return const Left(ServerFailure('Failed to update ATS config'));
    }
  }

  @override
  Future<Either<Failure, List<Announcement>>> getAllAnnouncements() async {
    try {
      return Right(await dataSource.getAllAnnouncements());
    } catch (e) {
      return const Left(ServerFailure('Failed to load announcements'));
    }
  }

  @override
  Future<Either<Failure, Announcement>> addAnnouncement(
    Announcement announcement,
  ) async {
    try {
      return Right(await dataSource.addAnnouncement(announcement));
    } catch (e) {
      return const Left(ServerFailure('Failed to add announcement'));
    }
  }

  @override
  Future<Either<Failure, Announcement>> updateAnnouncement(
    Announcement announcement,
  ) async {
    try {
      return Right(await dataSource.updateAnnouncement(announcement));
    } catch (e) {
      return const Left(ServerFailure('Failed to update announcement'));
    }
  }

  @override
  Future<Either<Failure, Announcement>> toggleAnnouncement(String id) async {
    try {
      return Right(await dataSource.toggleAnnouncement(id));
    } catch (e) {
      return const Left(ServerFailure('Failed to toggle announcement'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAnnouncement(String id) async {
    try {
      await dataSource.deleteAnnouncement(id);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete announcement'));
    }
  }

  // ========== Notifications ==========
  @override
  Future<Either<Failure, List<AppNotification>>> getAllNotifications() async {
    try {
      return Right(await dataSource.getAllNotifications());
    } catch (e) {
      return const Left(ServerFailure('Failed to load notifications'));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> addNotification(
    AppNotification notification,
  ) async {
    try {
      return Right(await dataSource.addNotification(notification));
    } catch (e) {
      return const Left(ServerFailure('Failed to send notification'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNotification(String id) async {
    try {
      await dataSource.deleteNotification(id);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete notification'));
    }
  }
}
