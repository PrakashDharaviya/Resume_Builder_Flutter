import '../../features/admin/domain/entities/admin_stats.dart';
import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/auth/domain/entities/user.dart';
import 'admin_firestore_service.dart';

class AdminRepository {
  final AdminFirestoreService service;

  AdminRepository({AdminFirestoreService? service})
    : service = service ?? AdminFirestoreService();

  AdminStats getStats() => service.getStats();

  List<User> getUsers() => service.getUsers();
  User toggleBlock(String uid) => service.toggleBlock(uid);
  User togglePremium(String uid) => service.togglePremium(uid);

  List<ResumeTemplate> getTemplates() => service.getTemplates();
  ResumeTemplate addTemplate(ResumeTemplate template) =>
      service.addTemplate(template);
  ResumeTemplate updateTemplate(ResumeTemplate template) =>
      service.updateTemplate(template);
  void deleteTemplate(String id) => service.deleteTemplate(id);

  ATSConfig getAtsConfig() => service.getAtsConfig();
  ATSConfig saveAtsConfig(ATSConfig config) => service.saveAtsConfig(config);

  List<Announcement> getAnnouncements() => service.getAnnouncements();
  Announcement addAnnouncement(Announcement announcement) =>
      service.addAnnouncement(announcement);
  Announcement toggleAnnouncement(String id) => service.toggleAnnouncement(id);
  void deleteAnnouncement(String id) => service.deleteAnnouncement(id);
}
