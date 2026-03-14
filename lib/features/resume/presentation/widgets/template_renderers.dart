import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/resume.dart';

// ============================================================
// SAMPLE DATA — used by admin preview
// ============================================================

Resume get sampleResume => Resume(
  id: 'sample',
  userId: 'admin',
  title: 'Sample Resume',
  personalInfo: const PersonalInfo(
    firstName: 'Prakash',
    lastName: 'Dharaviya',
    email: 'prakash.dharaviya@email.com',
    phone: '+91 98765 43210',
    location: 'Ahmedabad, Gujarat',
    website: 'prakash.dev',
    summary:
        'Passionate and detail-oriented Flutter developer with 2+ years of experience building cross-platform mobile and web applications. Proficient in Dart, Firebase, REST APIs, and modern UI/UX design principles.',
  ),
  education: [
    Education(
      id: 'edu1',
      degree: 'Master of Computer Applications (MCA)',
      institution: 'Gujarat Technological University',
      fieldOfStudy: 'Computer Science',
      startDate: DateTime(2024, 7),
      endDate: DateTime(2026, 5),
      currentlyStudying: true,
      grade: '8.5 CGPA',
    ),
    Education(
      id: 'edu2',
      degree: 'Bachelor of Computer Applications (BCA)',
      institution: 'Saurashtra University',
      fieldOfStudy: 'Computer Applications',
      startDate: DateTime(2021, 7),
      endDate: DateTime(2024, 5),
      grade: '9.0 CGPA',
    ),
  ],
  skills: const [
    Skill(id: 's1', name: 'Flutter', category: 'Mobile', proficiency: 'Expert'),
    Skill(id: 's2', name: 'Dart', category: 'Languages', proficiency: 'Expert'),
    Skill(id: 's3', name: 'Firebase', category: 'Backend', proficiency: 'Advanced'),
    Skill(id: 's4', name: 'REST APIs', category: 'Backend', proficiency: 'Advanced'),
    Skill(id: 's5', name: 'Git', category: 'Tools', proficiency: 'Advanced'),
    Skill(id: 's6', name: 'Java', category: 'Languages', proficiency: 'Intermediate'),
    Skill(id: 's7', name: 'UI/UX Design', category: 'Design', proficiency: 'Advanced'),
  ],
  experience: [
    Experience(
      id: 'exp1',
      jobTitle: 'Flutter Developer Intern',
      company: 'TechVista Solutions',
      startDate: DateTime(2024, 1),
      endDate: DateTime(2024, 6),
      location: 'Ahmedabad',
      description: 'Developed cross-platform mobile applications using Flutter and Firebase.',
      responsibilities: [
        'Built 3 production-ready mobile apps with Flutter',
        'Integrated Firebase Authentication and Cloud Firestore',
        'Implemented responsive UI designs for mobile and tablet',
      ],
    ),
  ],
  projects: const [
    Project(
      id: 'p1',
      name: 'ResumeIQ – AI Resume Builder',
      description:
          'A cross-platform resume builder with ATS scoring, multiple templates, and PDF export.',
      technologies: ['Flutter', 'Firebase', 'Dart', 'BLoC'],
      projectLink: 'github.com/prakash/resumeiq',
    ),
    Project(
      id: 'p2',
      name: 'SchoolEduERP',
      description:
          'Complete school management ERP with attendance, marks, and communication modules.',
      technologies: ['Flutter', 'Node.js', 'MongoDB'],
    ),
  ],
  certifications: [
    Certification(
      id: 'c1',
      name: 'Google Flutter Developer',
      issuingOrganization: 'Google',
      issueDate: DateTime(2024, 3),
      credentialId: 'GFD-2024-1234',
    ),
  ],
  achievements: const [
    Achievement(
      id: 'a1',
      title: 'Best Project Award',
      description: 'Won first place in university project showcase for ResumeIQ app.',
    ),
  ],
  languages: const [
    Language(id: 'l1', name: 'English', proficiency: 'Fluent'),
    Language(id: 'l2', name: 'Hindi', proficiency: 'Native'),
    Language(id: 'l3', name: 'Gujarati', proficiency: 'Native'),
  ],
  socialLinks: const SocialLinks(
    linkedin: 'linkedin.com/in/prakash-dharaviya',
    github: 'github.com/prakash',
  ),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  atsScore: 85,
);

// ============================================================
// PROFESSIONAL Template
// ============================================================

class ProfessionalTemplateRenderer extends StatelessWidget {
  final Resume resume;
  const ProfessionalTemplateRenderer({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF1A365D);
    const accentColor = Color(0xFF2B6CB0);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: headerColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resume.personalInfo?.fullName ?? '',
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16, runSpacing: 6,
                  children: [
                    if (resume.personalInfo?.email != null)
                      _iconText(Icons.email, resume.personalInfo!.email, Colors.white70),
                    if (resume.personalInfo?.phone != null)
                      _iconText(Icons.phone, resume.personalInfo!.phone!, Colors.white70),
                    if (resume.personalInfo?.location != null)
                      _iconText(Icons.location_on, resume.personalInfo!.location!, Colors.white70),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.personalInfo?.summary != null) ...[
                  _sectionTitle('PROFESSIONAL SUMMARY', accentColor),
                  const SizedBox(height: 8),
                  Text(resume.personalInfo!.summary!,
                      style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151))),
                  const SizedBox(height: 20),
                ],

                if (resume.experience.isNotEmpty) ...[
                  _sectionTitle('EXPERIENCE', accentColor),
                  const SizedBox(height: 8),
                  ...resume.experience.map((e) => _experienceItem(e)),
                  const SizedBox(height: 20),
                ],

                if (resume.education.isNotEmpty) ...[
                  _sectionTitle('EDUCATION', accentColor),
                  const SizedBox(height: 8),
                  ...resume.education.map((e) => _educationItem(e)),
                  const SizedBox(height: 20),
                ],

                if (resume.skills.isNotEmpty) ...[
                  _sectionTitle('SKILLS', accentColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: resume.skills.map((s) => Chip(
                      label: Text(s.name, style: const TextStyle(fontSize: 12)),
                      backgroundColor: accentColor.withValues(alpha: 0.1),
                      side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                if (resume.projects.isNotEmpty) ...[
                  _sectionTitle('PROJECTS', accentColor),
                  const SizedBox(height: 8),
                  ...resume.projects.map((p) => _projectItem(p, accentColor)),
                  const SizedBox(height: 20),
                ],

                if (resume.certifications.isNotEmpty) ...[
                  _sectionTitle('CERTIFICATIONS', accentColor),
                  const SizedBox(height: 8),
                  ...resume.certifications.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• ${c.name} — ${c.issuingOrganization}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                    ),
                  )),
                  const SizedBox(height: 20),
                ],

                if (resume.languages.isNotEmpty) ...[
                  _sectionTitle('LANGUAGES', accentColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    children: resume.languages.map((l) => Text(
                      '${l.name} (${l.proficiency})',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODERN Template (Two-column with sidebar)
// ============================================================

class ModernTemplateRenderer extends StatelessWidget {
  final Resume resume;
  const ModernTemplateRenderer({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    const sidebarColor = Color(0xFF0F172A);
    const accentColor = Color(0xFF38BDF8);

    return Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          if (isWide) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sidebar
                  SizedBox(
                    width: 220,
                    child: Container(
                      color: sidebarColor,
                      padding: const EdgeInsets.all(20),
                      child: _sidebar(accentColor),
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _mainContent(accentColor),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: sidebarColor,
                  padding: const EdgeInsets.all(20),
                  child: _sidebar(accentColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _mainContent(accentColor),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _sidebar(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar circle
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.6)]),
            ),
            child: Center(
              child: Text(
                (resume.personalInfo?.firstName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            resume.personalInfo?.fullName ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),

        // Contact info
        _sidebarLabel('CONTACT', accent),
        const SizedBox(height: 8),
        if (resume.personalInfo?.email != null)
          _sidebarItem(Icons.email, resume.personalInfo!.email),
        if (resume.personalInfo?.phone != null)
          _sidebarItem(Icons.phone, resume.personalInfo!.phone!),
        if (resume.personalInfo?.location != null)
          _sidebarItem(Icons.location_on, resume.personalInfo!.location!),

        const SizedBox(height: 20),

        // Skills
        if (resume.skills.isNotEmpty) ...[
          _sidebarLabel('SKILLS', accent),
          const SizedBox(height: 8),
          ...resume.skills.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.circle, size: 6, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.name,
                      style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ),
              ],
            ),
          )),
        ],

        const SizedBox(height: 20),
        // Languages
        if (resume.languages.isNotEmpty) ...[
          _sidebarLabel('LANGUAGES', accent),
          const SizedBox(height: 8),
          ...resume.languages.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('${l.name} — ${l.proficiency}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          )),
        ],
      ],
    );
  }

  Widget _sidebarLabel(String text, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accent, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Container(height: 2, width: 30, color: accent),
      ],
    );
  }

  Widget _sidebarItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _mainContent(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resume.personalInfo?.summary != null) ...[
          _sectionTitle('ABOUT ME', accent),
          const SizedBox(height: 8),
          Text(resume.personalInfo!.summary!,
              style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151))),
          const SizedBox(height: 20),
        ],

        if (resume.experience.isNotEmpty) ...[
          _sectionTitle('WORK EXPERIENCE', accent),
          const SizedBox(height: 8),
          ...resume.experience.map((e) => _experienceItem(e)),
          const SizedBox(height: 20),
        ],

        if (resume.education.isNotEmpty) ...[
          _sectionTitle('EDUCATION', accent),
          const SizedBox(height: 8),
          ...resume.education.map((e) => _educationItem(e)),
          const SizedBox(height: 20),
        ],

        if (resume.projects.isNotEmpty) ...[
          _sectionTitle('PROJECTS', accent),
          const SizedBox(height: 8),
          ...resume.projects.map((p) => _projectItem(p, accent)),
          const SizedBox(height: 20),
        ],

        if (resume.certifications.isNotEmpty) ...[
          _sectionTitle('CERTIFICATIONS', accent),
          const SizedBox(height: 8),
          ...resume.certifications.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• ${c.name} — ${c.issuingOrganization}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
          )),
        ],
      ],
    );
  }
}

// ============================================================
// MINIMAL Template
// ============================================================

class MinimalTemplateRenderer extends StatelessWidget {
  final Resume resume;
  const MinimalTemplateRenderer({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1F2937);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            resume.personalInfo?.fullName ?? '',
            style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.w300, color: textColor, letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          // Contact row
          Wrap(
            spacing: 8,
            children: [
              if (resume.personalInfo?.email != null)
                Text(resume.personalInfo!.email,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              if (resume.personalInfo?.phone != null) ...[
                const Text('|', style: TextStyle(fontSize: 12, color: Color(0xFFD1D5DB))),
                Text(resume.personalInfo!.phone!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
              if (resume.personalInfo?.location != null) ...[
                const Text('|', style: TextStyle(fontSize: 12, color: Color(0xFFD1D5DB))),
                Text(resume.personalInfo!.location!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(height: 0.5, color: const Color(0xFFD1D5DB)),

          if (resume.personalInfo?.summary != null) ...[
            const SizedBox(height: 20),
            Text(resume.personalInfo!.summary!,
                style: const TextStyle(fontSize: 13, height: 1.7, color: Color(0xFF4B5563), fontStyle: FontStyle.italic)),
          ],

          if (resume.experience.isNotEmpty) ...[
            const SizedBox(height: 24),
            _minimalSection('Experience'),
            ...resume.experience.map((e) => _experienceItem(e)),
          ],

          if (resume.education.isNotEmpty) ...[
            const SizedBox(height: 24),
            _minimalSection('Education'),
            ...resume.education.map((e) => _educationItem(e)),
          ],

          if (resume.skills.isNotEmpty) ...[
            const SizedBox(height: 24),
            _minimalSection('Skills'),
            const SizedBox(height: 6),
            Text(
              resume.skills.map((s) => s.name).join('  •  '),
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.8),
            ),
          ],

          if (resume.projects.isNotEmpty) ...[
            const SizedBox(height: 24),
            _minimalSection('Projects'),
            ...resume.projects.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                  Text(p.description,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
                ],
              ),
            )),
          ],

          if (resume.certifications.isNotEmpty) ...[
            const SizedBox(height: 24),
            _minimalSection('Certifications'),
            ...resume.certifications.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${c.name} — ${c.issuingOrganization}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
            )),
          ],

          if (resume.languages.isNotEmpty) ...[
            const SizedBox(height: 24),
            _minimalSection('Languages'),
            const SizedBox(height: 4),
            Text(
              resume.languages.map((l) => '${l.name} (${l.proficiency})').join('  •  '),
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _minimalSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 2)),
        const SizedBox(height: 4),
        Container(height: 0.5, color: const Color(0xFFD1D5DB)),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ============================================================
// CREATIVE Template
// ============================================================

class CreativeTemplateRenderer extends StatelessWidget {
  final Resume resume;
  const CreativeTemplateRenderer({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    const gradient1 = Color(0xFF6366F1);
    const gradient2 = Color(0xFFA855F7);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [gradient1, gradient2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          (resume.personalInfo?.firstName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.personalInfo?.fullName ?? '',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          if (resume.experience.isNotEmpty)
                            Text(
                              resume.experience.first.jobTitle,
                              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12, runSpacing: 6,
                  children: [
                    if (resume.personalInfo?.email != null)
                      _creativeBadge(Icons.email, resume.personalInfo!.email),
                    if (resume.personalInfo?.phone != null)
                      _creativeBadge(Icons.phone, resume.personalInfo!.phone!),
                    if (resume.personalInfo?.location != null)
                      _creativeBadge(Icons.location_on, resume.personalInfo!.location!),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.personalInfo?.summary != null) ...[
                  _creativeSection('✦ About Me', gradient1),
                  const SizedBox(height: 8),
                  Text(resume.personalInfo!.summary!,
                      style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151))),
                  const SizedBox(height: 20),
                ],

                if (resume.experience.isNotEmpty) ...[
                  _creativeSection('💼 Experience', gradient1),
                  const SizedBox(height: 8),
                  ...resume.experience.map((e) => _experienceItem(e)),
                  const SizedBox(height: 20),
                ],

                if (resume.education.isNotEmpty) ...[
                  _creativeSection('🎓 Education', gradient1),
                  const SizedBox(height: 8),
                  ...resume.education.map((e) => _educationItem(e)),
                  const SizedBox(height: 20),
                ],

                if (resume.skills.isNotEmpty) ...[
                  _creativeSection('⚡ Skills', gradient1),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: resume.skills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [gradient1.withValues(alpha: 0.1), gradient2.withValues(alpha: 0.1)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gradient1.withValues(alpha: 0.3)),
                      ),
                      child: Text(s.name, style: TextStyle(fontSize: 12, color: gradient1, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                if (resume.projects.isNotEmpty) ...[
                  _creativeSection('🚀 Projects', gradient1),
                  const SizedBox(height: 8),
                  ...resume.projects.map((p) => _projectItem(p, gradient1)),
                  const SizedBox(height: 20),
                ],

                if (resume.certifications.isNotEmpty) ...[
                  _creativeSection('🏆 Certifications', gradient1),
                  const SizedBox(height: 8),
                  ...resume.certifications.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• ${c.name} — ${c.issuingOrganization}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                  )),
                ],

                if (resume.languages.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _creativeSection('🌐 Languages', gradient1),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    children: resume.languages.map((l) => Text(
                      '${l.name} (${l.proficiency})',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _creativeBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _creativeSection(String title, Color color) {
    return Text(title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color));
  }
}

// ============================================================
// CLASSIC Template
// ============================================================

class ClassicTemplateRenderer extends StatelessWidget {
  final Resume resume;
  const ClassicTemplateRenderer({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF1F2937);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Centered header
          Text(
            resume.personalInfo?.fullName ?? '',
            style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: headerColor, letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, alignment: WrapAlignment.center,
            children: [
              if (resume.personalInfo?.email != null)
                Text(resume.personalInfo!.email,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              if (resume.personalInfo?.phone != null) ...[
                const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
                Text(resume.personalInfo!.phone!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
              if (resume.personalInfo?.location != null) ...[
                const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
                Text(resume.personalInfo!.location!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 2, width: 60, color: headerColor),

          // Body (left-aligned)
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.personalInfo?.summary != null) ...[
                  _classicSection('Summary'),
                  Text(resume.personalInfo!.summary!,
                      style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151))),
                  const SizedBox(height: 20),
                ],

                if (resume.experience.isNotEmpty) ...[
                  _classicSection('Professional Experience'),
                  ...resume.experience.map((e) => _experienceItem(e)),
                  const SizedBox(height: 20),
                ],

                if (resume.education.isNotEmpty) ...[
                  _classicSection('Education'),
                  ...resume.education.map((e) => _educationItem(e)),
                  const SizedBox(height: 20),
                ],

                if (resume.skills.isNotEmpty) ...[
                  _classicSection('Technical Skills'),
                  const SizedBox(height: 6),
                  _classicSkillsTable(),
                  const SizedBox(height: 20),
                ],

                if (resume.projects.isNotEmpty) ...[
                  _classicSection('Projects'),
                  ...resume.projects.map((p) => _projectItem(p, headerColor)),
                  const SizedBox(height: 20),
                ],

                if (resume.certifications.isNotEmpty) ...[
                  _classicSection('Certifications'),
                  ...resume.certifications.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• ${c.name} — ${c.issuingOrganization}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                  )),
                  const SizedBox(height: 20),
                ],

                if (resume.languages.isNotEmpty) ...[
                  _classicSection('Languages'),
                  Wrap(
                    spacing: 16,
                    children: resume.languages.map((l) => Text(
                      '${l.name} (${l.proficiency})',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _classicSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), letterSpacing: 1.5)),
        const SizedBox(height: 3),
        Container(height: 1.5, color: const Color(0xFF1F2937)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _classicSkillsTable() {
    final byCategory = <String, List<Skill>>{};
    for (final s in resume.skills) {
      final cat = s.category ?? 'Other';
      byCategory.putIfAbsent(cat, () => []).add(s);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: byCategory.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text('${e.key}:',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
            ),
            Expanded(
              child: Text(e.value.map((s) => s.name).join(', '),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ============================================================
// SHARED HELPERS (used across templates)
// ============================================================

Widget _sectionTitle(String title, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)),
      const SizedBox(height: 4),
      Container(height: 2, width: 40, color: color),
    ],
  );
}

Widget _iconText(IconData icon, String text, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Flexible(child: Text(text, style: TextStyle(fontSize: 12, color: color), overflow: TextOverflow.ellipsis)),
    ],
  );
}

Widget _experienceItem(Experience exp) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exp.jobTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        const SizedBox(height: 2),
        Text(
          '${exp.company}${exp.location != null ? ' • ${exp.location}' : ''}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 2),
        Text(
          '${DateFormatter.formatMonthYear(exp.startDate)} – ${exp.currentlyWorking ? 'Present' : DateFormatter.formatMonthYear(exp.endDate!)}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        if (exp.description != null) ...[
          const SizedBox(height: 4),
          Text(exp.description!, style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF374151))),
        ],
        if (exp.responsibilities.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...exp.responsibilities.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                Expanded(child: Text(r, style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF374151)))),
              ],
            ),
          )),
        ],
      ],
    ),
  );
}

Widget _educationItem(Education edu) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(edu.degree,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        const SizedBox(height: 2),
        Text(edu.institution,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
        Text(
          '${DateFormatter.formatMonthYear(edu.startDate)} – ${edu.currentlyStudying ? 'Present' : DateFormatter.formatMonthYear(edu.endDate!)}${edu.grade != null ? ' • ${edu.grade}' : ''}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    ),
  );
}

Widget _projectItem(Project proj, Color accent) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(proj.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        const SizedBox(height: 2),
        Text(proj.description,
            style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF374151))),
        if (proj.technologies.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: proj.technologies.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(t, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
        ],
      ],
    ),
  );
}
