import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/user/data/resume_firestore_service.dart';

class UserRepository {
  final ResumeFirestoreService service;

  UserRepository({ResumeFirestoreService? service})
    : service = service ?? ResumeFirestoreService();

  Future<List<Resume>> getResumes() => service.getResumes();
  Future<List<ResumeTemplate>> getActiveTemplates() => service.getActiveTemplates();
  Future<ATSConfig> getAtsConfig() => service.getAtsConfig();
  Future<List<Announcement>> getActiveAnnouncements() =>
      service.getActiveAnnouncements();
}
