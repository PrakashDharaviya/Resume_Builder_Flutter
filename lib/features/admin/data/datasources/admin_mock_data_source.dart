import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/ats_config.dart';
import '../../domain/entities/resume_template.dart';
import '../../../auth/domain/entities/user.dart';

class AdminMockDataSource {
  // ========== Mock Users ==========
  final List<User> _users = [
    const User(
      uid: 'admin_001',
      email: 'admin@resumeiq.com',
      displayName: 'Admin User',
      role: 'admin',
      isBlocked: false,
      isPremium: true,
    ),
    const User(
      uid: 'user_001',
      email: 'john.doe@gmail.com',
      displayName: 'John Doe',
      role: 'user',
      isBlocked: false,
      isPremium: true,
    ),
    const User(
      uid: 'user_002',
      email: 'jane.smith@gmail.com',
      displayName: 'Jane Smith',
      role: 'user',
      isBlocked: false,
      isPremium: false,
    ),
    const User(
      uid: 'user_003',
      email: 'alex.wilson@gmail.com',
      displayName: 'Alex Wilson',
      role: 'user',
      isBlocked: true,
      isPremium: false,
    ),
    const User(
      uid: 'user_004',
      email: 'sarah.jones@gmail.com',
      displayName: 'Sarah Jones',
      role: 'user',
      isBlocked: false,
      isPremium: true,
    ),
    const User(
      uid: 'user_005',
      email: 'mike.brown@gmail.com',
      displayName: 'Mike Brown',
      role: 'user',
      isBlocked: false,
      isPremium: false,
    ),
    const User(
      uid: 'user_006',
      email: 'emily.davis@gmail.com',
      displayName: 'Emily Davis',
      role: 'user',
      isBlocked: false,
      isPremium: false,
    ),
    const User(
      uid: 'user_007',
      email: 'robert.taylor@gmail.com',
      displayName: 'Robert Taylor',
      role: 'user',
      isBlocked: true,
      isPremium: false,
    ),
  ];

  // ========== Mock Templates ==========
  final List<ResumeTemplate> _templates = [
    ResumeTemplate(
      id: 'tmpl_001',
      name: 'Classic Professional',
      isActive: true,
      isPremium: false,
      layoutJson: '{"style": "classic", "columns": 1}',
      previewImage: 'assets/templates/classic.png',
      createdAt: DateTime(2024, 1, 15),
    ),
    ResumeTemplate(
      id: 'tmpl_002',
      name: 'Modern Minimalist',
      isActive: true,
      isPremium: true,
      layoutJson: '{"style": "modern", "columns": 2}',
      previewImage: 'assets/templates/modern.png',
      createdAt: DateTime(2024, 2, 10),
    ),
    ResumeTemplate(
      id: 'tmpl_003',
      name: 'Creative Portfolio',
      isActive: true,
      isPremium: true,
      layoutJson: '{"style": "creative", "columns": 2}',
      previewImage: 'assets/templates/creative.png',
      createdAt: DateTime(2024, 3, 5),
    ),
    ResumeTemplate(
      id: 'tmpl_004',
      name: 'Executive Suite',
      isActive: false,
      isPremium: true,
      layoutJson: '{"style": "executive", "columns": 1}',
      previewImage: 'assets/templates/executive.png',
      createdAt: DateTime(2024, 4, 20),
    ),
    ResumeTemplate(
      id: 'tmpl_005',
      name: 'Tech Developer',
      isActive: true,
      isPremium: false,
      layoutJson: '{"style": "tech", "columns": 2}',
      previewImage: 'assets/templates/tech.png',
      createdAt: DateTime(2024, 5, 12),
    ),
  ];

  // ========== Mock ATS Config ==========
  ATSConfig _atsConfig = const ATSConfig(
    keywordWeight: 30,
    skillWeight: 25,
    grammarWeight: 15,
    experienceWeight: 20,
    formattingWeight: 10,
  );

  // ========== Mock Announcements ==========
  final List<Announcement> _announcements = [
    Announcement(
      id: 'ann_001',
      title: 'Welcome to ResumeIQ!',
      message:
          'Build professional resumes with our AI-powered platform. Get started today!',
      createdAt: DateTime(2024, 6, 1),
      isActive: true,
    ),
    Announcement(
      id: 'ann_002',
      title: 'New Templates Available',
      message:
          'Check out our latest premium resume templates designed for tech professionals.',
      createdAt: DateTime(2024, 7, 15),
      isActive: true,
    ),
    Announcement(
      id: 'ann_003',
      title: 'System Maintenance',
      message: 'Scheduled maintenance on August 5th from 2 AM to 4 AM UTC.',
      createdAt: DateTime(2024, 8, 1),
      isActive: false,
    ),
  ];

  // ========== Dashboard Stats ==========
  AdminStats getAdminStats() {
    final premiumCount = _users.where((u) => u.isPremium).length;
    final blockedCount = _users.where((u) => u.isBlocked).length;
    final activeTemplates = _templates.where((t) => t.isActive).length;

    return AdminStats(
      totalUsers: _users.length,
      totalResumes: 42,
      premiumUsers: premiumCount,
      avgAtsScore: 72.5,
      mostUsedTemplate: 'Classic Professional',
      activeTemplates: activeTemplates,
      blockedUsers: blockedCount,
      todaySignups: 3,
    );
  }

  // ========== Template Operations ==========
  List<ResumeTemplate> getAllTemplates() => List.unmodifiable(_templates);

  ResumeTemplate addTemplate(ResumeTemplate template) {
    final newTemplate = template.copyWith(
      id: 'tmpl_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _templates.add(newTemplate);
    return newTemplate;
  }

  ResumeTemplate updateTemplate(ResumeTemplate template) {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _templates[index] = template;
      return template;
    }
    throw Exception('Template not found');
  }

  void deleteTemplate(String id) {
    _templates.removeWhere((t) => t.id == id);
  }

  // ========== User Operations ==========
  List<User> getAllUsers() => List.unmodifiable(_users);

  User toggleBlockUser(String uid) {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      final user = _users[index];
      final updated = user.copyWith(isBlocked: !user.isBlocked);
      _users[index] = updated;
      return updated;
    }
    throw Exception('User not found');
  }

  User togglePremiumUser(String uid) {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      final user = _users[index];
      final updated = user.copyWith(isPremium: !user.isPremium);
      _users[index] = updated;
      return updated;
    }
    throw Exception('User not found');
  }

  // ========== ATS Config Operations ==========
  ATSConfig getATSConfig() => _atsConfig;

  ATSConfig updateATSConfig(ATSConfig config) {
    _atsConfig = config;
    return _atsConfig;
  }

  // ========== Announcement Operations ==========
  List<Announcement> getAllAnnouncements() => List.unmodifiable(_announcements);

  Announcement addAnnouncement(Announcement announcement) {
    final newAnnouncement = announcement.copyWith(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _announcements.insert(0, newAnnouncement);
    return newAnnouncement;
  }

  Announcement toggleAnnouncement(String id) {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index != -1) {
      final ann = _announcements[index];
      final updated = ann.copyWith(isActive: !ann.isActive);
      _announcements[index] = updated;
      return updated;
    }
    throw Exception('Announcement not found');
  }

  void deleteAnnouncement(String id) {
    _announcements.removeWhere((a) => a.id == id);
  }
}
