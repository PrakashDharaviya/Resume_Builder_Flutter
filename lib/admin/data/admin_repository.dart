import '../../features/admin/domain/entities/admin_stats.dart';
import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/auth/domain/entities/user.dart';
import 'admin_firestore_service.dart';

class AdminRepository {
  final AdminFirestoreService _service;

  AdminRepository({AdminFirestoreService? service})
    : _service = service ?? AdminFirestoreService();

  AdminStats getStats() => _service.getStats();

  List<User> getUsers() => _service.getUsers();
  User toggleBlock(String uid) => _service.toggleBlock(uid);
  User togglePremium(String uid) => _service.togglePremium(uid);

  List<ResumeTemplate> getTemplates() => _service.getTemplates();
  ResumeTemplate addTemplate(ResumeTemplate template) =>
      _service.addTemplate(template);
  ResumeTemplate updateTemplate(ResumeTemplate template) =>
      _service.updateTemplate(template);
  void deleteTemplate(String id) => _service.deleteTemplate(id);

  ATSConfig getAtsConfig() => _service.getAtsConfig();
  ATSConfig saveAtsConfig(ATSConfig config) => _service.saveAtsConfig(config);

  List<Announcement> getAnnouncements() => _service.getAnnouncements();
  Announcement addAnnouncement(Announcement announcement) =>
      _service.addAnnouncement(announcement);
  Announcement toggleAnnouncement(String id) => _service.toggleAnnouncement(id);
  void deleteAnnouncement(String id) => _service.deleteAnnouncement(id);
}
