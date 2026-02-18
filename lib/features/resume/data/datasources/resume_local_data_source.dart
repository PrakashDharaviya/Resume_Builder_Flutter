import '../models/resume_model.dart';

abstract class ResumeLocalDataSource {
  Future<List<ResumeModel>> getAllResumes();
  Future<ResumeModel> getResumeById(String id);
  Future<ResumeModel> createResume(ResumeModel resume);
  Future<ResumeModel> updateResume(ResumeModel resume);
  Future<void> deleteResume(String id);
}

class ResumeLocalDataSourceImpl implements ResumeLocalDataSource {
  // Mock data storage
  final List<ResumeModel> _mockResumes = [
    ResumeModel(
      id: 'resume_1',
      userId: 'mock_uid_123',
      title: 'Software Engineer Resume',
      personalInfo: const PersonalInfoModel(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        location: 'San Francisco, CA',
        website: 'https://johndoe.dev',
        summary:
            'Experienced software engineer with 5+ years of expertise in Flutter and mobile development.',
      ),
      education: [
        EducationModel(
          id: 'edu_1',
          degree: 'Bachelor of Science',
          institution: 'Stanford University',
          fieldOfStudy: 'Computer Science',
          startDate: DateTime.parse('2015-09-01T00:00:00.000Z'),
          endDate: DateTime.parse('2019-06-01T00:00:00.000Z'),
          grade: '3.8 GPA',
          currentlyStudying: false,
        ),
      ],
      skills: const [
        SkillModel(
          id: 'skill_1',
          name: 'Flutter',
          category: 'Mobile',
          proficiency: 'Expert',
        ),
        SkillModel(
          id: 'skill_2',
          name: 'Dart',
          category: 'Programming',
          proficiency: 'Expert',
        ),
        SkillModel(
          id: 'skill_3',
          name: 'Firebase',
          category: 'Backend',
          proficiency: 'Advanced',
        ),
        SkillModel(
          id: 'skill_4',
          name: 'State Management',
          category: 'Mobile',
          proficiency: 'Expert',
        ),
        SkillModel(
          id: 'skill_5',
          name: 'REST API',
          category: 'Backend',
          proficiency: 'Advanced',
        ),
      ],
      experience: [
        ExperienceModel(
          id: 'exp_1',
          jobTitle: 'Senior Flutter Developer',
          company: 'TechCorp Inc.',
          employmentType: 'Full-time',
          startDate: DateTime.parse('2021-01-01T00:00:00.000Z'),
          currentlyWorking: true,
          location: 'San Francisco, CA',
          description: 'Leading mobile development team',
          responsibilities: [
            'Developed and maintained 3 production Flutter apps',
            'Implemented clean architecture and SOLID principles',
            'Mentored junior developers',
          ],
        ),
        ExperienceModel(
          id: 'exp_2',
          jobTitle: 'Flutter Developer',
          company: 'StartupXYZ',
          employmentType: 'Full-time',
          startDate: DateTime.parse('2019-07-01T00:00:00.000Z'),
          endDate: DateTime.parse('2020-12-31T00:00:00.000Z'),
          currentlyWorking: false,
          location: 'Remote',
          description: 'Built mobile applications',
          responsibilities: [
            'Built 2 mobile apps from scratch',
            'Integrated Firebase services',
            'Implemented push notifications',
          ],
        ),
      ],
      projects: const [
        ProjectModel(
          id: 'proj_1',
          name: 'E-commerce Mobile App',
          description: 'Full-featured e-commerce app with payment integration',
          technologies: ['Flutter', 'Firebase', 'Stripe'],
          projectLink: 'https://github.com/johndoe/ecommerce-app',
        ),
        ProjectModel(
          id: 'proj_2',
          name: 'Task Management App',
          description: 'Productivity app with offline sync',
          technologies: ['Flutter', 'SQLite', 'Provider'],
          projectLink: 'https://github.com/johndoe/task-app',
        ),
      ],
      certifications: [
        CertificationModel(
          id: 'cert_1',
          name: 'Google Associate Android Developer',
          issuingOrganization: 'Google',
          issueDate: DateTime.parse('2020-05-15T00:00:00.000Z'),
          credentialId: 'GOOGLE-123456',
        ),
      ],
      achievements: [
        AchievementModel(
          id: 'ach_1',
          title: 'App of the Year Award',
          description: 'Won best mobile app award at TechConf 2022',
          date: DateTime.parse('2022-10-01T00:00:00.000Z'),
        ),
      ],
      languages: const [
        LanguageModel(id: 'lang_1', name: 'English', proficiency: 'Native'),
        LanguageModel(
          id: 'lang_2',
          name: 'Spanish',
          proficiency: 'Intermediate',
        ),
      ],
      socialLinks: const SocialLinksModel(
        linkedin: 'https://linkedin.com/in/johndoe',
        github: 'https://github.com/johndoe',
        portfolio: 'https://johndoe.dev',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      atsScore: 87,
    ),
    ResumeModel(
      id: 'resume_2',
      userId: 'mock_uid_123',
      title: 'Full Stack Developer Resume',
      personalInfo: const PersonalInfoModel(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        location: 'San Francisco, CA',
      ),
      skills: const [
        SkillModel(
          id: 'skill_6',
          name: 'React',
          category: 'Frontend',
          proficiency: 'Advanced',
        ),
        SkillModel(
          id: 'skill_7',
          name: 'Node.js',
          category: 'Backend',
          proficiency: 'Advanced',
        ),
        SkillModel(
          id: 'skill_8',
          name: 'MongoDB',
          category: 'Database',
          proficiency: 'Intermediate',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      atsScore: 72,
    ),
  ];

  @override
  Future<List<ResumeModel>> getAllResumes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockResumes;
  }

  @override
  Future<ResumeModel> getResumeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockResumes.firstWhere((resume) => resume.id == id);
  }

  @override
  Future<ResumeModel> createResume(ResumeModel resume) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockResumes.add(resume);
    return resume;
  }

  @override
  Future<ResumeModel> updateResume(ResumeModel resume) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockResumes.indexWhere((r) => r.id == resume.id);
    if (index != -1) {
      _mockResumes[index] = resume;
    }
    return resume;
  }

  @override
  Future<void> deleteResume(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockResumes.removeWhere((resume) => resume.id == id);
  }
}
