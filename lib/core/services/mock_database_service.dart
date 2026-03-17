import 'package:resumebuilder/features/admin/data/datasources/admin_mock_data_source.dart';
import 'package:resumebuilder/features/admin/domain/entities/admin_stats.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';
import 'package:resumebuilder/features/resume/data/datasources/resume_local_data_source.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/injection_container.dart' as di;

class MockDatabaseService {
  MockDatabaseService._();

  static final MockDatabaseService instance = MockDatabaseService._();

  AdminMockDataSource get adminSource => di.sl<AdminMockDataSource>();
  ResumeLocalDataSource get resumeSource => di.sl<ResumeLocalDataSource>();

  Future<AdminStats> getAdminStats() => adminSource.getAdminStats();

  Future<List<User>> getUsers() => adminSource.getAllUsers();
  Future<User> toggleUserBlock(String uid) => adminSource.toggleBlockUser(uid);
  Future<User> toggleUserPremium(String uid) => adminSource.togglePremiumUser(uid);

  Future<List<ResumeTemplate>> getTemplates() => adminSource.getAllTemplates();
  Future<ResumeTemplate> addTemplate(ResumeTemplate template) =>
      adminSource.addTemplate(template);
  Future<ResumeTemplate> updateTemplate(ResumeTemplate template) =>
      adminSource.updateTemplate(template);
  Future<void> deleteTemplate(String id) => adminSource.deleteTemplate(id);

  Future<ATSConfig> getAtsConfig() => adminSource.getATSConfig();
  Future<ATSConfig> updateAtsConfig(ATSConfig config) =>
      adminSource.updateATSConfig(config);

  Future<List<Announcement>> getAnnouncements() => adminSource.getAllAnnouncements();
  Future<List<Announcement>> getActiveAnnouncements() async =>
      (await adminSource.getAllAnnouncements()).where((a) => a.isActive).toList();
  Future<Announcement> addAnnouncement(Announcement announcement) =>
      adminSource.addAnnouncement(announcement);
  Future<Announcement> toggleAnnouncement(String id) =>
      adminSource.toggleAnnouncement(id);
  Future<void> deleteAnnouncement(String id) => adminSource.deleteAnnouncement(id);

  Future<List<Resume>> getResumes() async {
    final models = await resumeSource.getAllResumes();
    return List<Resume>.from(models);
  }
}
