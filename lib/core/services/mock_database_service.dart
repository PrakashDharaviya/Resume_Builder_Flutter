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

  AdminMockDataSource get _adminSource => di.sl<AdminMockDataSource>();
  ResumeLocalDataSource get _resumeSource => di.sl<ResumeLocalDataSource>();

  AdminStats getAdminStats() => _adminSource.getAdminStats();

  List<User> getUsers() => _adminSource.getAllUsers();
  User toggleUserBlock(String uid) => _adminSource.toggleBlockUser(uid);
  User toggleUserPremium(String uid) => _adminSource.togglePremiumUser(uid);

  List<ResumeTemplate> getTemplates() => _adminSource.getAllTemplates();
  ResumeTemplate addTemplate(ResumeTemplate template) =>
      _adminSource.addTemplate(template);
  ResumeTemplate updateTemplate(ResumeTemplate template) =>
      _adminSource.updateTemplate(template);
  void deleteTemplate(String id) => _adminSource.deleteTemplate(id);

  ATSConfig getAtsConfig() => _adminSource.getATSConfig();
  ATSConfig updateAtsConfig(ATSConfig config) =>
      _adminSource.updateATSConfig(config);

  List<Announcement> getAnnouncements() => _adminSource.getAllAnnouncements();
  List<Announcement> getActiveAnnouncements() =>
      _adminSource.getAllAnnouncements().where((a) => a.isActive).toList();
  Announcement addAnnouncement(Announcement announcement) =>
      _adminSource.addAnnouncement(announcement);
  Announcement toggleAnnouncement(String id) =>
      _adminSource.toggleAnnouncement(id);
  void deleteAnnouncement(String id) => _adminSource.deleteAnnouncement(id);

  Future<List<Resume>> getResumes() async {
    final models = await _resumeSource.getAllResumes();
    return List<Resume>.from(models);
  }
}
