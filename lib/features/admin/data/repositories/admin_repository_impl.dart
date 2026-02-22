import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/ats_config.dart';
import '../../domain/entities/resume_template.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../auth/domain/entities/user.dart';
import '../datasources/admin_mock_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminMockDataSource dataSource;

  AdminRepositoryImpl({required this.dataSource});

  @override
  Either<Failure, AdminStats> getAdminStats() {
    try {
      return Right(dataSource.getAdminStats());
    } catch (e) {
      return const Left(ServerFailure('Failed to load admin stats'));
    }
  }

  @override
  Either<Failure, List<ResumeTemplate>> getAllTemplates() {
    try {
      return Right(dataSource.getAllTemplates());
    } catch (e) {
      return const Left(ServerFailure('Failed to load templates'));
    }
  }

  @override
  Either<Failure, ResumeTemplate> addTemplate(ResumeTemplate template) {
    try {
      return Right(dataSource.addTemplate(template));
    } catch (e) {
      return const Left(ServerFailure('Failed to add template'));
    }
  }

  @override
  Either<Failure, ResumeTemplate> updateTemplate(ResumeTemplate template) {
    try {
      return Right(dataSource.updateTemplate(template));
    } catch (e) {
      return const Left(ServerFailure('Failed to update template'));
    }
  }

  @override
  Either<Failure, Unit> deleteTemplate(String id) {
    try {
      dataSource.deleteTemplate(id);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete template'));
    }
  }

  @override
  Either<Failure, List<User>> getAllUsers() {
    try {
      return Right(dataSource.getAllUsers());
    } catch (e) {
      return const Left(ServerFailure('Failed to load users'));
    }
  }

  @override
  Either<Failure, User> toggleBlockUser(String uid) {
    try {
      return Right(dataSource.toggleBlockUser(uid));
    } catch (e) {
      return const Left(ServerFailure('Failed to toggle block status'));
    }
  }

  @override
  Either<Failure, User> togglePremiumUser(String uid) {
    try {
      return Right(dataSource.togglePremiumUser(uid));
    } catch (e) {
      return const Left(ServerFailure('Failed to toggle premium status'));
    }
  }

  @override
  Either<Failure, ATSConfig> getATSConfig() {
    try {
      return Right(dataSource.getATSConfig());
    } catch (e) {
      return const Left(ServerFailure('Failed to load ATS config'));
    }
  }

  @override
  Either<Failure, ATSConfig> updateATSConfig(ATSConfig config) {
    try {
      return Right(dataSource.updateATSConfig(config));
    } catch (e) {
      return const Left(ServerFailure('Failed to update ATS config'));
    }
  }

  @override
  Either<Failure, List<Announcement>> getAllAnnouncements() {
    try {
      return Right(dataSource.getAllAnnouncements());
    } catch (e) {
      return const Left(ServerFailure('Failed to load announcements'));
    }
  }

  @override
  Either<Failure, Announcement> addAnnouncement(Announcement announcement) {
    try {
      return Right(dataSource.addAnnouncement(announcement));
    } catch (e) {
      return const Left(ServerFailure('Failed to add announcement'));
    }
  }

  @override
  Either<Failure, Announcement> toggleAnnouncement(String id) {
    try {
      return Right(dataSource.toggleAnnouncement(id));
    } catch (e) {
      return const Left(ServerFailure('Failed to toggle announcement'));
    }
  }

  @override
  Either<Failure, Unit> deleteAnnouncement(String id) {
    try {
      dataSource.deleteAnnouncement(id);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete announcement'));
    }
  }
}
