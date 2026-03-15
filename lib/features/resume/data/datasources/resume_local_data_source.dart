import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resumebuilder/core/errors/exceptions.dart';
import 'package:resumebuilder/features/resume/data/models/resume_model.dart';

abstract class ResumeLocalDataSource {
  Future<List<ResumeModel>> getAllResumes();
  Future<ResumeModel> getResumeById(String id);
  Future<ResumeModel> createResume(ResumeModel resume);
  Future<ResumeModel> updateResume(ResumeModel resume);
  Future<void> deleteResume(String id);
}

class ResumeLocalDataSourceImpl implements ResumeLocalDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _resumesCollection =>
      _firestore.collection('resumes');

  @override
  Future<List<ResumeModel>> getAllResumes() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _resumesCollection
        .where('userId', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => ResumeModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<ResumeModel> getResumeById(String id) async {
    final doc = await _resumesCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Resume not found');
    }
    return ResumeModel.fromJson(doc.data()!);
  }

  @override
  Future<ResumeModel> createResume(ResumeModel resume) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AuthException('User must be signed in to create a resume');
    }

    final now = DateTime.now();
    final data = resume.toJson();
    data['userId'] = uid;
    data['createdAt'] = now.toIso8601String();
    data['updatedAt'] = now.toIso8601String();

    await _resumesCollection.doc(resume.id).set(data);

    return ResumeModel.fromJson(data);
  }

  @override
  Future<ResumeModel> updateResume(ResumeModel resume) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AuthException('User must be signed in to update a resume');
    }

    final now = DateTime.now();
    final data = resume.toJson();
    data['userId'] = uid;
    data['updatedAt'] = now.toIso8601String();

    await _resumesCollection.doc(resume.id).set(data, SetOptions(merge: true));

    return ResumeModel.fromJson(data);
  }

  @override
  Future<void> deleteResume(String id) async {
    await _resumesCollection.doc(id).delete();
  }
}
