import '../../features/admin/domain/entities/announcement.dart';
import '../../features/admin/domain/entities/ats_config.dart';
import '../../features/admin/domain/entities/resume_template.dart';
import '../../features/resume/domain/entities/resume.dart';
import 'resume_firestore_service.dart';

class UserRepository {
  final ResumeFirestoreService _service;

  UserRepository({ResumeFirestoreService? service})
    : _service = service ?? ResumeFirestoreService();

  Future<List<Resume>> getResumes() => _service.getResumes();
  List<ResumeTemplate> getActiveTemplates() => _service.getActiveTemplates();
  ATSConfig getAtsConfig() => _service.getAtsConfig();
  List<Announcement> getActiveAnnouncements() =>
      _service.getActiveAnnouncements();
}
