import '../../injection_container.dart' as di;
import '../../features/admin/data/datasources/admin_mock_data_source.dart';
import '../../features/resume/data/datasources/resume_local_data_source.dart';
import '../../features/admin/domain/entities/admin_stats.dart';
import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/resume/domain/entities/resume.dart';

class MockDatabaseService {
  MockDatabaseService._();

  static final MockDatabaseService instance = MockDatabaseService._();

  AdminMockDataSource get adminSource => di.sl<AdminMockDataSource>();
  ResumeLocalDataSource get resumeSource => di.sl<ResumeLocalDataSource>();

  AdminStats getAdminStats() => adminSource.getAdminStats();

  List<User> getUsers() => adminSource.getAllUsers();
  User toggleUserBlock(String uid) => adminSource.toggleBlockUser(uid);
  User toggleUserPremium(String uid) => adminSource.togglePremiumUser(uid);

  List<ResumeTemplate> getTemplates() => adminSource.getAllTemplates();
  ResumeTemplate addTemplate(ResumeTemplate template) =>
      adminSource.addTemplate(template);
  ResumeTemplate updateTemplate(ResumeTemplate template) =>
      adminSource.updateTemplate(template);
  void deleteTemplate(String id) => adminSource.deleteTemplate(id);

  ATSConfig getAtsConfig() => adminSource.getATSConfig();
  ATSConfig updateAtsConfig(ATSConfig config) =>
      adminSource.updateATSConfig(config);

  List<Announcement> getAnnouncements() => adminSource.getAllAnnouncements();
  List<Announcement> getActiveAnnouncements() =>
      adminSource.getAllAnnouncements().where((a) => a.isActive).toList();
  Announcement addAnnouncement(Announcement announcement) =>
      adminSource.addAnnouncement(announcement);
  Announcement toggleAnnouncement(String id) =>
      adminSource.toggleAnnouncement(id);
  void deleteAnnouncement(String id) => adminSource.deleteAnnouncement(id);

  Future<List<Resume>> getResumes() async {
    final models = await resumeSource.getAllResumes();
    return List<Resume>.from(models);
  }
}
