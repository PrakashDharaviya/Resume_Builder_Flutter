import '../../core/services/mock_database_service.dart';
import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/resume/domain/entities/resume.dart';

class ResumeFirestoreService {
  final MockDatabaseService db;

  ResumeFirestoreService({MockDatabaseService? databaseService})
    : db = databaseService ?? MockDatabaseService.instance;

  Future<List<Resume>> getResumes() => db.getResumes();

  Future<List<ResumeTemplate>> getActiveTemplates() async =>
      (await db.getTemplates()).where((t) => t.isActive).toList();

  Future<ATSConfig> getAtsConfig() => db.getAtsConfig();

  Future<List<Announcement>> getActiveAnnouncements() => db.getActiveAnnouncements();
}
