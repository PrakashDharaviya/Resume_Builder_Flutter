import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resumebuilder/core/errors/exceptions.dart';
import 'package:resumebuilder/features/resume/data/models/resume_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract
// ---------------------------------------------------------------------------
abstract class ResumeRemoteDataSource {
  /// Returns all resumes belonging to the currently signed-in user.
  Future<List<ResumeModel>> getUserResumes();

  /// Returns a single resume by [id] for the current user.
  Future<ResumeModel> getResumeById(String id);

  /// Creates a new resume document under the user's sub-collection.
  Future<ResumeModel> createResume(ResumeModel resume);

  /// Updates an existing resume document (merge).
  Future<ResumeModel> updateResume(ResumeModel resume);

  /// Deletes a resume document by [id].
  Future<void> deleteResume(String id);
}

// ---------------------------------------------------------------------------
// Firestore implementation — stores resumes at:
//   users/{uid}/resumes/{resumeId}
// ---------------------------------------------------------------------------
class ResumeRemoteDataSourceImpl implements ResumeRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth firebaseAuth;

  ResumeRemoteDataSourceImpl({
    required this.firebaseFirestore,
    required this.firebaseAuth,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the current user's UID or throws [AuthException].
  String get _uid {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException('User must be signed in to manage resumes.');
    }
    return user.uid;
  }

  /// Returns a reference to the current user's `resumes` sub-collection.
  CollectionReference<Map<String, dynamic>> get _resumesRef =>
      firebaseFirestore.collection('users').doc(_uid).collection('resumes');

  // ── getUserResumes ──────────────────────────────────────────────────────

  @override
  Future<List<ResumeModel>> getUserResumes() async {
    try {
      final snapshot = await _resumesRef
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ensure the doc ID is in the map
        data['userId'] = _uid;
        return ResumeModel.fromJson(data);
      }).toList();
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to fetch resumes: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch resumes: ${e.toString()}');
    }
  }

  // ── getResumeById ──────────────────────────────────────────────────────

  @override
  Future<ResumeModel> getResumeById(String id) async {
    try {
      final doc = await _resumesRef.doc(id).get();

      if (!doc.exists) {
        throw const NotFoundException('Resume not found.');
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      data['userId'] = _uid;
      return ResumeModel.fromJson(data);
    } on AuthException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to fetch resume: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch resume: ${e.toString()}');
    }
  }

  // ── createResume ───────────────────────────────────────────────────────

  @override
  Future<ResumeModel> createResume(ResumeModel resume) async {
    try {
      final now = DateTime.now();
      final data = resume.toJson();

      // Overwrite timestamps and ownership fields.
      data['userId'] = _uid;
      data['createdAt'] = now.toIso8601String();
      data['updatedAt'] = now.toIso8601String();

      // Use the model's ID as the doc ID to keep it deterministic.
      await _resumesRef.doc(resume.id).set(data);

      data['id'] = resume.id;
      return ResumeModel.fromJson(data);
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create resume: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create resume: ${e.toString()}');
    }
  }

  // ── updateResume ───────────────────────────────────────────────────────

  @override
  Future<ResumeModel> updateResume(ResumeModel resume) async {
    try {
      final now = DateTime.now();
      final data = resume.toJson();

      data['userId'] = _uid;
      data['updatedAt'] = now.toIso8601String();

      // Merge so partial updates don't wipe unset fields.
      await _resumesRef.doc(resume.id).set(data, SetOptions(merge: true));

      data['id'] = resume.id;
      return ResumeModel.fromJson(data);
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update resume: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update resume: ${e.toString()}');
    }
  }

  // ── deleteResume ───────────────────────────────────────────────────────

  @override
  Future<void> deleteResume(String id) async {
    try {
      // Access _uid to enforce sign-in check before deletion.
      final _ = _uid;
      await _resumesRef.doc(id).delete();
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete resume: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete resume: ${e.toString()}');
    }
  }
}
