import '../../core/services/mock_database_service.dart';
import '../../features/admin/domain/entities/admin_stats.dart';
import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/auth/domain/entities/user.dart';

class AdminFirestoreService {
  final MockDatabaseService db;

  AdminFirestoreService({MockDatabaseService? databaseService})
    : db = databaseService ?? MockDatabaseService.instance;

  AdminStats getStats() => db.getAdminStats();

  List<User> getUsers() => db.getUsers();
  User toggleBlock(String uid) => db.toggleUserBlock(uid);
  User togglePremium(String uid) => db.toggleUserPremium(uid);

  List<ResumeTemplate> getTemplates() => db.getTemplates();
  ResumeTemplate addTemplate(ResumeTemplate template) =>
      db.addTemplate(template);
  ResumeTemplate updateTemplate(ResumeTemplate template) =>
      db.updateTemplate(template);
  void deleteTemplate(String id) => db.deleteTemplate(id);

  ATSConfig getAtsConfig() => db.getAtsConfig();
  ATSConfig saveAtsConfig(ATSConfig config) => db.updateAtsConfig(config);

  List<Announcement> getAnnouncements() => db.getAnnouncements();
  Announcement addAnnouncement(Announcement announcement) =>
      db.addAnnouncement(announcement);
  Announcement toggleAnnouncement(String id) => db.toggleAnnouncement(id);
  void deleteAnnouncement(String id) => db.deleteAnnouncement(id);
}
