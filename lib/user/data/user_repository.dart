import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/resume/domain/entities/resume.dart';
import 'resume_firestore_service.dart';

class UserRepository {
  final ResumeFirestoreService service;

  UserRepository({ResumeFirestoreService? service})
    : service = service ?? ResumeFirestoreService();

  Future<List<Resume>> getResumes() => service.getResumes();
  List<ResumeTemplate> getActiveTemplates() => service.getActiveTemplates();
  ATSConfig getAtsConfig() => service.getAtsConfig();
  List<Announcement> getActiveAnnouncements() =>
      service.getActiveAnnouncements();
}
