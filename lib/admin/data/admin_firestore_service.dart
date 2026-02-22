import '../../core/services/mock_database_service.dart';
import '../../features/admin/domain/entities/admin_stats.dart';
import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/auth/domain/entities/user.dart';

class AdminFirestoreService {
  final MockDatabaseService _db;

  AdminFirestoreService({MockDatabaseService? databaseService})
    : _db = databaseService ?? MockDatabaseService.instance;

  AdminStats getStats() => _db.getAdminStats();

  List<User> getUsers() => _db.getUsers();
  User toggleBlock(String uid) => _db.toggleUserBlock(uid);
  User togglePremium(String uid) => _db.toggleUserPremium(uid);

  List<ResumeTemplate> getTemplates() => _db.getTemplates();
  ResumeTemplate addTemplate(ResumeTemplate template) =>
      _db.addTemplate(template);
  ResumeTemplate updateTemplate(ResumeTemplate template) =>
      _db.updateTemplate(template);
  void deleteTemplate(String id) => _db.deleteTemplate(id);

  ATSConfig getAtsConfig() => _db.getAtsConfig();
  ATSConfig saveAtsConfig(ATSConfig config) => _db.updateAtsConfig(config);

  List<Announcement> getAnnouncements() => _db.getAnnouncements();
  Announcement addAnnouncement(Announcement announcement) =>
      _db.addAnnouncement(announcement);
  Announcement toggleAnnouncement(String id) => _db.toggleAnnouncement(id);
  void deleteAnnouncement(String id) => _db.deleteAnnouncement(id);
}
