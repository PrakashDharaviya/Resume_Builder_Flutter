class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  // Resume Routes
  static const String createResume = '/create-resume';
  static const String editResume = '/edit-resume';
  static const String resumeEditor = '/resume-editor';
  static const String resumePreview = '/resume-preview';
  static const String templateSelection = '/template-selection';

  // ATS Routes
  static const String atsAnalysis = '/ats-analysis';
  static const String atsResult = '/ats-result';

  // Export Routes
  static const String exportPDF = '/export-pdf';

  // Settings Routes
  static const String settings = '/settings';

  // Admin Routes
  static const String authCheck = '/auth-check';
  static const String adminDashboard = '/admin/dashboard';
  static const String manageUsers = '/admin/users';
  static const String manageTemplates = '/admin/templates';
  static const String atsSettings = '/admin/ats-settings';
  static const String analytics = '/admin/analytics';
  static const String announcements = '/admin/announcements';
}
