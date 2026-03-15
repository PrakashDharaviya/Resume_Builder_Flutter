import 'package:resumebuilder/core/services/mock_database_service.dart';
import 'package:resumebuilder/features/admin/domain/entities/admin_stats.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';

class AdminFirestoreService {
  final MockDatabaseService db;

  AdminFirestoreService({MockDatabaseService? databaseService})
    : db = databaseService ?? MockDatabaseService.instance;

  Future<AdminStats> getStats() => db.getAdminStats();

  Future<List<User>> getUsers() => db.getUsers();
  Future<User> toggleBlock(String uid) => db.toggleUserBlock(uid);
  Future<User> togglePremium(String uid) => db.toggleUserPremium(uid);

  Future<List<ResumeTemplate>> getTemplates() => db.getTemplates();
  Future<ResumeTemplate> addTemplate(ResumeTemplate template) =>
      db.addTemplate(template);
  Future<ResumeTemplate> updateTemplate(ResumeTemplate template) =>
      db.updateTemplate(template);
  Future<void> deleteTemplate(String id) => db.deleteTemplate(id);

  Future<ATSConfig> getAtsConfig() => db.getAtsConfig();
  Future<ATSConfig> saveAtsConfig(ATSConfig config) => db.updateAtsConfig(config);

  Future<List<Announcement>> getAnnouncements() => db.getAnnouncements();
  Future<Announcement> addAnnouncement(Announcement announcement) =>
      db.addAnnouncement(announcement);
  Future<Announcement> toggleAnnouncement(String id) => db.toggleAnnouncement(id);
  Future<void> deleteAnnouncement(String id) => db.deleteAnnouncement(id);
}
