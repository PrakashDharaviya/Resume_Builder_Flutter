import 'package:resumebuilder/features/admin/domain/entities/admin_stats.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';
import 'package:resumebuilder/admin/data/admin_firestore_service.dart';

class AdminRepository {
  final AdminFirestoreService service;

  AdminRepository({AdminFirestoreService? service})
    : service = service ?? AdminFirestoreService();

  Future<AdminStats> getStats() => service.getStats();

  Future<List<User>> getUsers() => service.getUsers();
  Future<User> toggleBlock(String uid) => service.toggleBlock(uid);
  Future<User> togglePremium(String uid) => service.togglePremium(uid);

  Future<List<ResumeTemplate>> getTemplates() => service.getTemplates();
  Future<ResumeTemplate> addTemplate(ResumeTemplate template) =>
      service.addTemplate(template);
  Future<ResumeTemplate> updateTemplate(ResumeTemplate template) =>
      service.updateTemplate(template);
  Future<void> deleteTemplate(String id) => service.deleteTemplate(id);

  Future<ATSConfig> getAtsConfig() => service.getAtsConfig();
  Future<ATSConfig> saveAtsConfig(ATSConfig config) => service.saveAtsConfig(config);

  Future<List<Announcement>> getAnnouncements() => service.getAnnouncements();
  Future<Announcement> addAnnouncement(Announcement announcement) =>
      service.addAnnouncement(announcement);
  Future<Announcement> toggleAnnouncement(String id) => service.toggleAnnouncement(id);
  Future<void> deleteAnnouncement(String id) => service.deleteAnnouncement(id);
}
