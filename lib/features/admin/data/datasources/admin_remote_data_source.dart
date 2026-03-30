import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resumebuilder/features/admin/domain/entities/admin_stats.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/app_notification.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStats> getAdminStats();
  Future<List<ResumeTemplate>> getAllTemplates();
  Future<ResumeTemplate> addTemplate(ResumeTemplate template);
  Future<ResumeTemplate> updateTemplate(ResumeTemplate template);
  Future<void> deleteTemplate(String id);
  Future<List<User>> getAllUsers();
  Future<User> toggleBlockUser(String uid);
  Future<User> togglePremiumUser(String uid);
  Future<ATSConfig> getATSConfig();
  Future<ATSConfig> updateATSConfig(ATSConfig config);
  Future<List<Announcement>> getAllAnnouncements();
  Future<Announcement> addAnnouncement(Announcement announcement);
  Future<Announcement> updateAnnouncement(Announcement announcement);
  Future<Announcement> toggleAnnouncement(String id);
  Future<void> deleteAnnouncement(String id);

  // Notifications
  Future<List<AppNotification>> getAllNotifications();
  Future<AppNotification> addNotification(AppNotification notification);
  Future<void> deleteNotification(String id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _templatesCol =>
      firestore.collection('templates');
  CollectionReference<Map<String, dynamic>> get _announcementsCol =>
      firestore.collection('announcements');
  CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      firestore.collection('notifications');
  DocumentReference<Map<String, dynamic>> get _atsConfigDoc =>
      firestore.collection('config').doc('ats');

  // ========== Dashboard Stats ==========
  @override
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
    } catch (e) {
      print('Error fetching users: $e');
    }

    // Resumes (using collectionGroup to search across all users)
    try {
      final resumesQuery = firestore.collectionGroup('resumes');
      final resumesCountSnap = await resumesQuery.count().get();
      totalResumes = resumesCountSnap.count ?? 0;
    } catch (e) {
      print('Error fetching resumes: $e');
    }

    // Templates
    try {
      final templatesCountSnap = await _templatesCol
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      activeTemplates = templatesCountSnap.count ?? 0;
    } catch (e) {
      print('Error fetching templates: $e');
    }

    return AdminStats(
      totalUsers: totalUsers,
      totalResumes: totalResumes,
      premiumUsers: premiumCount,
      avgAtsScore: 0, // Mocked for now as we'd need expensive aggregation
      mostUsedTemplate: 'Classic Professional',
      activeTemplates: activeTemplates,
      blockedUsers: blockedCount,
      todaySignups: todaySignups,
    );
  }

  // ========== Template Operations ==========
  @override
  Future<List<ResumeTemplate>> getAllTemplates() async {
    final snap = await _templatesCol.get();
    final templates = snap.docs.map((doc) {
      final d = doc.data();
      return ResumeTemplate(
        id: doc.id,
        name: (d['name'] as String?) ?? '',
        isActive: (d['isActive'] as bool?) ?? true,
        isPremium: (d['isPremium'] as bool?) ?? false,
        templateType: (d['templateType'] as String?) ?? 'professional',
        layoutJson: (d['layoutJson'] as String?) ?? '{}',
        previewImage: (d['previewImage'] as String?) ?? '',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
    templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return templates;
  }

  @override
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

  @override
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

  @override
  Future<void> deleteTemplate(String id) async {
    await _templatesCol.doc(id).delete();
  }

  // ========== User Operations ==========
  @override
  Future<List<User>> getAllUsers() async {
    final snap = await _usersCol.get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return User(
        uid: doc.id,
        email: (d['email'] as String?) ?? '',
        displayName: (d['displayName'] as String?) ?? '',
        photoURL: d['photoURL'] as String?,
        role: (d['role'] as String?) ?? 'user',
        isBlocked: (d['isBlocked'] as bool?) ?? false,
        isPremium: (d['isPremium'] as bool?) ?? false,
      );
    }).toList();
  }

  @override
  Future<User> toggleBlockUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    final currentBlocked = (doc.data()?['isBlocked'] as bool?) ?? false;
    await _usersCol.doc(uid).update({'isBlocked': !currentBlocked});
    final updated = await _usersCol.doc(uid).get();
    final d = updated.data()!;
    return User(
      uid: uid,
      email: (d['email'] as String?) ?? '',
      displayName: (d['displayName'] as String?) ?? '',
      photoURL: d['photoURL'] as String?,
      role: (d['role'] as String?) ?? 'user',
      isBlocked: (d['isBlocked'] as bool?) ?? false,
      isPremium: (d['isPremium'] as bool?) ?? false,
    );
  }

  @override
  Future<User> togglePremiumUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    final currentPremium = (doc.data()?['isPremium'] as bool?) ?? false;
    await _usersCol.doc(uid).update({'isPremium': !currentPremium});
    final updated = await _usersCol.doc(uid).get();
    final d = updated.data()!;
    return User(
      uid: uid,
      email: (d['email'] as String?) ?? '',
      displayName: (d['displayName'] as String?) ?? '',
      photoURL: d['photoURL'] as String?,
      role: (d['role'] as String?) ?? 'user',
      isBlocked: (d['isBlocked'] as bool?) ?? false,
      isPremium: (d['isPremium'] as bool?) ?? false,
    );
  }

  // ========== ATS Config Operations ==========
  @override
  Future<ATSConfig> getATSConfig() async {
    final doc = await _atsConfigDoc.get();
    if (!doc.exists) {
      return const ATSConfig();
    }
    final d = doc.data()!;

    double readWeight(String key, double fallback) {
      final value = d[key];
      if (value is num) return value.toDouble();
      return fallback;
    }

    return ATSConfig(
      keywordWeight: readWeight('keywordWeight', 30),
      skillWeight: readWeight('skillWeight', 25),
      grammarWeight: readWeight('grammarWeight', 15),
      experienceWeight: readWeight('experienceWeight', 20),
      formattingWeight: readWeight('formattingWeight', 10),
    );
  }

  @override
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
  @override
  Future<List<Announcement>> getAllAnnouncements() async {
    final snap = await _announcementsCol.get();
    final announcements = snap.docs.map((doc) {
      final d = doc.data();
      return Announcement(
        id: doc.id,
        title: (d['title'] as String?) ?? '',
        message: (d['message'] as String?) ?? '',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isActive: (d['isActive'] as bool?) ?? true,
      );
    }).toList();
    announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return announcements;
  }

  @override
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

  @override
  Future<Announcement> updateAnnouncement(Announcement announcement) async {
    await _announcementsCol.doc(announcement.id).update({
      'title': announcement.title,
      'message': announcement.message,
      'isActive': announcement.isActive,
    });
    return announcement;
  }

  @override
  Future<Announcement> toggleAnnouncement(String id) async {
    final doc = await _announcementsCol.doc(id).get();
    if (!doc.exists) throw Exception('Announcement not found');
    final currentActive = (doc.data()?['isActive'] as bool?) ?? true;
    await _announcementsCol.doc(id).update({'isActive': !currentActive});
    final updated = await _announcementsCol.doc(id).get();
    final d = updated.data()!;
    return Announcement(
      id: id,
      title: (d['title'] as String?) ?? '',
      message: (d['message'] as String?) ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: (d['isActive'] as bool?) ?? true,
    );
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await _announcementsCol.doc(id).delete();
  }

  // ========== Notification Operations ==========
  @override
  Future<List<AppNotification>> getAllNotifications() async {
    final snap = await _notificationsCol
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return AppNotification(
        id: doc.id,
        title: (d['title'] as String?) ?? '',
        message: (d['message'] as String?) ?? '',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        type: (d['type'] as String?) ?? 'broadcast',
      );
    }).toList();
  }

  @override
  Future<AppNotification> addNotification(AppNotification notification) async {
    final id = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    await _notificationsCol.doc(id).set({
      'title': notification.title,
      'message': notification.message,
      'createdAt': Timestamp.fromDate(now),
      'type': notification.type,
    });
    return notification.copyWith(id: id, createdAt: now);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _notificationsCol.doc(id).delete();
  }
}
