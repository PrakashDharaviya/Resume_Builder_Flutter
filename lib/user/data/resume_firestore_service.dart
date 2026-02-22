import '../../core/services/mock_database_service.dart';
import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/resume/domain/entities/resume.dart';

class ResumeFirestoreService {
  final MockDatabaseService _db;

  ResumeFirestoreService({MockDatabaseService? databaseService})
    : _db = databaseService ?? MockDatabaseService.instance;

  Future<List<Resume>> getResumes() => _db.getResumes();

  List<ResumeTemplate> getActiveTemplates() =>
      _db.getTemplates().where((t) => t.isActive).toList();

  ATSConfig getAtsConfig() => _db.getAtsConfig();

  List<Announcement> getActiveAnnouncements() => _db.getActiveAnnouncements();
}
