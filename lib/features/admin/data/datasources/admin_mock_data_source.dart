import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/ats_config.dart';
import '../../domain/entities/resume_template.dart';
import '../../../auth/domain/entities/user.dart';

class AdminMockDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _resumesCol =>
      _firestore.collection('resumes');
  CollectionReference<Map<String, dynamic>> get _templatesCol =>
      _firestore.collection('templates');
  CollectionReference<Map<String, dynamic>> get _announcementsCol =>
      _firestore.collection('announcements');
  DocumentReference<Map<String, dynamic>> get _atsConfigDoc =>
      _firestore.collection('config').doc('ats');

  // ========== Dashboard Stats ==========
  Future<AdminStats> getAdminStats() async {
    int totalUsers = 0;
    int totalResumes = 0;
    int premiumCount = 0;
    int blockedCount = 0;
    int todaySignups = 0;
    int activeTemplates = 0;

    // Users
    try {
      final usersSnap = await _usersCol.get();
      totalUsers = usersSnap.size;
      final users = usersSnap.docs.map((d) => d.data()).toList();
      premiumCount = users.where((u) => u['isPremium'] == true).length;
      blockedCount = users.where((u) => u['isBlocked'] == true).length;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      todaySignups = users.where((u) {
        final createdAt = u['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().isAfter(todayStart);
        }
        return false;
      }).length;
    } catch (_) {}

    // Resumes
    try {
      final resumesSnap = await _resumesCol.get();
      totalResumes = resumesSnap.size;
    } catch (_) {}

    // Templates – count active in Dart to avoid needing a Firestore index
    try {
      final templatesSnap = await _templatesCol.get();
      activeTemplates = templatesSnap.docs
          .where((d) => d.data()['isActive'] == true)
          .length;
    } catch (_) {}

    return AdminStats(
      totalUsers: totalUsers,
      totalResumes: totalResumes,
      premiumUsers: premiumCount,
      avgAtsScore: 0,
      mostUsedTemplate: 'Classic Professional',
      activeTemplates: activeTemplates,
      blockedUsers: blockedCount,
      todaySignups: todaySignups,
    );
  }

  // ========== Template Operations ==========
  Future<List<ResumeTemplate>> getAllTemplates() async {
    final snap = await _templatesCol.get();
    final templates = snap.docs.map((doc) {
      final d = doc.data();
      return ResumeTemplate(
        id: doc.id,
        name: d['name'] ?? '',
        isActive: d['isActive'] ?? true,
        isPremium: d['isPremium'] ?? false,
        templateType: d['templateType'] ?? 'professional',
        layoutJson: d['layoutJson'] ?? '{}',
        previewImage: d['previewImage'] ?? '',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
    templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return templates;
  }

  Future<ResumeTemplate> addTemplate(ResumeTemplate template) async {
    final id = 'tmpl_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final data = {
      'name': template.name,
      'isActive': template.isActive,
      'isPremium': template.isPremium,
      'templateType': template.templateType,
      'layoutJson': template.layoutJson,
      'previewImage': template.previewImage,
      'createdAt': Timestamp.fromDate(now),
    };
    await _templatesCol.doc(id).set(data);
    return template.copyWith(id: id, createdAt: now);
  }

  Future<ResumeTemplate> updateTemplate(ResumeTemplate template) async {
    await _templatesCol.doc(template.id).update({
      'name': template.name,
      'isActive': template.isActive,
      'isPremium': template.isPremium,
      'templateType': template.templateType,
      'layoutJson': template.layoutJson,
      'previewImage': template.previewImage,
    });
    return template;
  }

  Future<void> deleteTemplate(String id) async {
    await _templatesCol.doc(id).delete();
  }

  // ========== User Operations ==========
  Future<List<User>> getAllUsers() async {
    final snap = await _usersCol.get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return User(
        uid: doc.id,
        email: d['email'] ?? '',
        displayName: d['displayName'] ?? '',
        photoURL: d['photoURL'],
        role: d['role'] ?? 'user',
        isBlocked: d['isBlocked'] ?? false,
        isPremium: d['isPremium'] ?? false,
      );
    }).toList();
  }

  Future<User> toggleBlockUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    final currentBlocked = doc.data()?['isBlocked'] ?? false;
    await _usersCol.doc(uid).update({'isBlocked': !currentBlocked});
    final updated = await _usersCol.doc(uid).get();
    final d = updated.data()!;
    return User(
      uid: uid,
      email: d['email'] ?? '',
      displayName: d['displayName'] ?? '',
      photoURL: d['photoURL'],
      role: d['role'] ?? 'user',
      isBlocked: d['isBlocked'] ?? false,
      isPremium: d['isPremium'] ?? false,
    );
  }

  Future<User> togglePremiumUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    final currentPremium = doc.data()?['isPremium'] ?? false;
    await _usersCol.doc(uid).update({'isPremium': !currentPremium});
    final updated = await _usersCol.doc(uid).get();
    final d = updated.data()!;
    return User(
      uid: uid,
      email: d['email'] ?? '',
      displayName: d['displayName'] ?? '',
      photoURL: d['photoURL'],
      role: d['role'] ?? 'user',
      isBlocked: d['isBlocked'] ?? false,
      isPremium: d['isPremium'] ?? false,
    );
  }

  // ========== ATS Config Operations ==========
  Future<ATSConfig> getATSConfig() async {
    final doc = await _atsConfigDoc.get();
    if (!doc.exists) {
      return const ATSConfig();
    }
    final d = doc.data()!;
    return ATSConfig(
      keywordWeight: (d['keywordWeight'] ?? 30).toDouble(),
      skillWeight: (d['skillWeight'] ?? 25).toDouble(),
      grammarWeight: (d['grammarWeight'] ?? 15).toDouble(),
      experienceWeight: (d['experienceWeight'] ?? 20).toDouble(),
      formattingWeight: (d['formattingWeight'] ?? 10).toDouble(),
    );
  }

  Future<ATSConfig> updateATSConfig(ATSConfig config) async {
    await _atsConfigDoc.set({
      'keywordWeight': config.keywordWeight,
      'skillWeight': config.skillWeight,
      'grammarWeight': config.grammarWeight,
      'experienceWeight': config.experienceWeight,
      'formattingWeight': config.formattingWeight,
    });
    return config;
  }

  // ========== Announcement Operations ==========
  Future<List<Announcement>> getAllAnnouncements() async {
    final snap = await _announcementsCol.get();
    final announcements = snap.docs.map((doc) {
      final d = doc.data();
      return Announcement(
        id: doc.id,
        title: d['title'] ?? '',
        message: d['message'] ?? '',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isActive: d['isActive'] ?? true,
      );
    }).toList();
    announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return announcements;
  }

  Future<Announcement> addAnnouncement(Announcement announcement) async {
    final id = 'ann_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    await _announcementsCol.doc(id).set({
      'title': announcement.title,
      'message': announcement.message,
      'createdAt': Timestamp.fromDate(now),
      'isActive': announcement.isActive,
    });
    return announcement.copyWith(id: id, createdAt: now);
  }

  Future<Announcement> toggleAnnouncement(String id) async {
    final doc = await _announcementsCol.doc(id).get();
    if (!doc.exists) throw Exception('Announcement not found');
    final currentActive = doc.data()?['isActive'] ?? true;
    await _announcementsCol.doc(id).update({'isActive': !currentActive});
    final updated = await _announcementsCol.doc(id).get();
    final d = updated.data()!;
    return Announcement(
      id: id,
      title: d['title'] ?? '',
      message: d['message'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: d['isActive'] ?? true,
    );
  }

  Future<void> deleteAnnouncement(String id) async {
    await _announcementsCol.doc(id).delete();
  }
}
