import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/presentation/bloc/resume_bloc.dart';
import 'package:resumebuilder/features/resume/presentation/bloc/resume_event.dart';
import 'package:resumebuilder/features/resume/presentation/widgets/template_renderer_factory.dart';

class ResumeEditorPage extends StatefulWidget {
  final Resume? resume;
  final String templateType;

  const ResumeEditorPage({
    super.key,
    this.resume,
    this.templateType = 'professional',
  });

  @override
  State<ResumeEditorPage> createState() => ResumeEditorPageState();
}

class ResumeEditorPageState extends State<ResumeEditorPage> {
  // Personal Info controllers
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();
  final summaryCtrl = TextEditingController();

  // Section data lists
  final List<Map<String, dynamic>> educations = [];
  final List<Map<String, dynamic>> experiences = [];
  final List<Map<String, dynamic>> skills = [];
  final List<Map<String, dynamic>> languages = [];
  final List<Map<String, dynamic>> projects = [];
  final List<Map<String, dynamic>> certifications = [];
  final List<Map<String, dynamic>> achievements = [];

  late final String _resumeId;
  bool _hasSavedOrAutoSaved = false;

  @override
  void initState() {
    super.initState();
    _resumeId =
        widget.resume?.id ?? 'resume_${DateTime.now().millisecondsSinceEpoch}';
    populateFromResume(widget.resume);
  }

  void populateFromResume(Resume? resume) {
    if (resume == null) return;

    // Personal info
    final pi = resume.personalInfo;
    if (pi != null) {
      firstNameCtrl.text = pi.firstName;
      lastNameCtrl.text = pi.lastName;
      emailCtrl.text = pi.email;
      phoneCtrl.text = pi.phone ?? '';
      locationCtrl.text = pi.location ?? '';
      websiteCtrl.text = pi.website ?? '';
      summaryCtrl.text = pi.summary ?? '';
    }

    final dateFmt = DateFormat('MMM yyyy');

    // Education
    for (final edu in resume.education) {
      educations.add({
        'degree': edu.degree,
        'institution': edu.institution,
        'field': edu.fieldOfStudy ?? '',
        'start': dateFmt.format(edu.startDate),
        'end': edu.currentlyStudying
            ? 'Present'
            : (edu.endDate != null ? dateFmt.format(edu.endDate!) : ''),
        'grade': edu.grade ?? '',
        'desc': edu.description ?? '',
      });
    }

    // Experience
    for (final exp in resume.experience) {
      experiences.add({
        'title': exp.jobTitle,
        'company': exp.company,
        'type': exp.employmentType ?? '',
        'start': dateFmt.format(exp.startDate),
        'end': exp.currentlyWorking
            ? 'Present'
            : (exp.endDate != null ? dateFmt.format(exp.endDate!) : ''),
        'location': exp.location ?? '',
        'desc': exp.description ?? '',
      });
    }

    // Skills
    for (final skill in resume.skills) {
      skills.add({
        'name': skill.name,
        'category': skill.category ?? '',
        'level': skill.proficiency ?? 'Intermediate',
      });
    }

    // Languages
    for (final lang in resume.languages) {
      languages.add({'name': lang.name, 'level': lang.proficiency});
    }

    // Projects
    for (final proj in resume.projects) {
      projects.add({
        'name': proj.name,
        'desc': proj.description,
        'tech': proj.technologies.join(', '),
        'link': proj.projectLink ?? '',
      });
    }

    // Certifications
    for (final cert in resume.certifications) {
      certifications.add({
        'name': cert.name,
        'org': cert.issuingOrganization,
        'date': dateFmt.format(cert.issueDate),
        'id': cert.credentialId ?? '',
        'url': cert.credentialUrl ?? '',
      });
    }

    // Achievements
    for (final ach in resume.achievements) {
      achievements.add({
        'title': ach.title,
        'desc': ach.description,
        'date': ach.date != null ? dateFmt.format(ach.date!) : '',
      });
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    websiteCtrl.dispose();
    summaryCtrl.dispose();
    super.dispose();
  }

  // ─── Generic section card ────────────────────────────────────────────────
  Widget sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: AppColors.primary, size: 20),
          ),
        ),
      ),
    );
  }

  // ─── Item card ───────────────────────────────────────────────────────────
  Widget itemCard({
    required String title,
    required String subtitle,
    String? trailing,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trailing,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.redAccent,
              ),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom-sheet helper ─────────────────────────────────────────────────
  Future<void> showSheet(Widget form) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: form,
        ),
      ),
    );
  }

  // ─── Sheet header widget ─────────────────────────────────────────────────
  Widget sheetHandle(String title) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EDUCATION
  // ═══════════════════════════════════════════════════════════════════════════
  void addOrEditEducation({Map<String, dynamic>? existing, int? index}) {
    final degreeCtrl = TextEditingController(
      text: (existing?['degree'] as String?) ?? '',
    );
    final institutionCtrl = TextEditingController(
      text: (existing?['institution'] as String?) ?? '',
    );
    final fieldCtrl = TextEditingController(
      text: (existing?['field'] as String?) ?? '',
    );
    final gradeCtrl = TextEditingController(
      text: (existing?['grade'] as String?) ?? '',
    );
    final startCtrl = TextEditingController(
      text: (existing?['start'] as String?) ?? '',
    );
    final endCtrl = TextEditingController(
      text: (existing?['end'] as String?) ?? '',
    );
    bool current = (existing?['current'] as bool?) ?? false;

    showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(index == null ? 'Add Education' : 'Edit Education'),
                field(
                  'Degree / Qualification',
                  degreeCtrl,
                  hint: 'e.g. Bachelor of Science',
                ),
                field(
                  'Institution',
                  institutionCtrl,
                  hint: 'e.g. Stanford University',
                ),
                field(
                  'Field of Study',
                  fieldCtrl,
                  hint: 'e.g. Computer Science',
                ),
                field('Grade / CGPA', gradeCtrl, hint: 'e.g. 3.8 GPA'),
                Row(
                  children: [
                    Expanded(
                      child: field('Start Year', startCtrl, hint: '2020'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: field(
                        'End Year',
                        endCtrl,
                        hint: '2024',
                        enabled: !current,
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Currently Studying'),
                  value: current,
                  onChanged: (v) => setS(() => current = v ?? false),
                ),
                const SizedBox(height: 16),
                saveBtn(() {
                  if (degreeCtrl.text.isEmpty || institutionCtrl.text.isEmpty) {
                    return;
                  }
                  final item = {
                    'degree': degreeCtrl.text,
                    'institution': institutionCtrl.text,
                    'field': fieldCtrl.text,
                    'grade': gradeCtrl.text,
                    'start': startCtrl.text,
                    'end': current ? 'Present' : endCtrl.text,
                    'current': current,
                  };
                  setState(() {
                    if (index == null) {
                      educations.add(item);
                    } else {
                      educations[index] = item;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPERIENCE
  // ═══════════════════════════════════════════════════════════════════════════
  void addOrEditExperience({Map<String, dynamic>? existing, int? index}) {
    final titleCtrl = TextEditingController(
      text: (existing?['title'] as String?) ?? '',
    );
    final companyCtrl = TextEditingController(
      text: (existing?['company'] as String?) ?? '',
    );
    final locationCtrl = TextEditingController(
      text: (existing?['location'] as String?) ?? '',
    );
    final startCtrl = TextEditingController(
      text: (existing?['start'] as String?) ?? '',
    );
    final endCtrl = TextEditingController(
      text: (existing?['end'] as String?) ?? '',
    );
    final descCtrl = TextEditingController(
      text: (existing?['desc'] as String?) ?? '',
    );
    bool current = (existing?['current'] as bool?) ?? false;

    showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(
                  index == null ? 'Add Experience' : 'Edit Experience',
                ),
                field('Job Title', titleCtrl, hint: 'e.g. Software Engineer'),
                field('Company', companyCtrl, hint: 'e.g. Google'),
                field(
                  'Location (optional)',
                  locationCtrl,
                  hint: 'e.g. Remote / Mumbai',
                ),
                Row(
                  children: [
                    Expanded(
                      child: field('Start', startCtrl, hint: 'Jan 2022'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: field(
                        'End',
                        endCtrl,
                        hint: 'Present',
                        enabled: !current,
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Currently Working'),
                  value: current,
                  onChanged: (v) => setS(() => current = v ?? false),
                ),
                field(
                  'Description / Responsibilities',
                  descCtrl,
                  hint: 'Describe your role and achievements…',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                saveBtn(() {
                  if (titleCtrl.text.isEmpty || companyCtrl.text.isEmpty) {
                    return;
                  }
                  final item = {
                    'title': titleCtrl.text,
                    'company': companyCtrl.text,
                    'location': locationCtrl.text,
                    'start': startCtrl.text,
                    'end': current ? 'Present' : endCtrl.text,
                    'current': current,
                    'desc': descCtrl.text,
                  };
                  setState(() {
                    if (index == null) {
                      experiences.add(item);
                    } else {
                      experiences[index] = item;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SKILLS
  // ═══════════════════════════════════════════════════════════════════════════
  void addOrEditSkill({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] as String?) ?? '',
    );
    final categoryCtrl = TextEditingController(
      text: (existing?['category'] as String?) ?? '',
    );
    String level = (existing?['level'] as String?) ?? 'Intermediate';

    showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(index == null ? 'Add Skill' : 'Edit Skill'),
                field('Skill Name', nameCtrl, hint: 'e.g. Flutter'),
                field(
                  'Category',
                  categoryCtrl,
                  hint: 'e.g. Mobile, Backend, Design',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Proficiency Level',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                      .map(
                        (l) => ChoiceChip(
                          label: Text(l),
                          selected: level == l,
                          onSelected: (_) => setS(() => level = l),
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                saveBtn(() {
                  if (nameCtrl.text.isEmpty) return;
                  final item = {
                    'name': nameCtrl.text,
                    'category': categoryCtrl.text,
                    'level': level,
                  };
                  setState(() {
                    if (index == null) {
                      skills.add(item);
                    } else {
                      skills[index] = item;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LANGUAGES
  // ═══════════════════════════════════════════════════════════════════════════
  void addOrEditLanguage({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] as String?) ?? '',
    );
    String level = (existing?['level'] as String?) ?? 'Fluent';

    showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(index == null ? 'Add Language' : 'Edit Language'),
                field('Language', nameCtrl, hint: 'e.g. English'),
                const SizedBox(height: 8),
                const Text(
                  'Proficiency Level',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Basic', 'Intermediate', 'Fluent', 'Native']
                      .map(
                        (l) => ChoiceChip(
                          label: Text(l),
                          selected: level == l,
                          onSelected: (_) => setS(() => level = l),
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                saveBtn(() {
                  if (nameCtrl.text.isEmpty) return;
                  final item = {'name': nameCtrl.text, 'level': level};
                  setState(() {
                    if (index == null) {
                      languages.add(item);
                    } else {
                      languages[index] = item;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROJECTS
  // ═══════════════════════════════════════════════════════════════════════════
  void addOrEditProject({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] as String?) ?? '',
    );
    final descCtrl = TextEditingController(
      text: (existing?['desc'] as String?) ?? '',
    );
    final techCtrl = TextEditingController(
      text: (existing?['tech'] as String?) ?? '',
    );
    final linkCtrl = TextEditingController(
      text: (existing?['link'] as String?) ?? '',
    );

    showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(index == null ? 'Add Project' : 'Edit Project'),
                field('Project Name', nameCtrl, hint: 'e.g. ResumeIQ App'),
                field(
                  'Description',
                  descCtrl,
                  hint: 'What does the project do?',
                  maxLines: 3,
                ),
                field(
                  'Technologies Used',
                  techCtrl,
                  hint: 'e.g. Flutter, Firebase, Node.js',
                ),
                field(
                  'Project Link (optional)',
                  linkCtrl,
                  hint: 'https://github.com/...',
                ),
                const SizedBox(height: 24),
                saveBtn(() {
                  if (nameCtrl.text.isEmpty) return;
                  final item = {
                    'name': nameCtrl.text,
                    'desc': descCtrl.text,
                    'tech': techCtrl.text,
                    'link': linkCtrl.text,
                  };
                  setState(() {
                    if (index == null) {
                      projects.add(item);
                    } else {
                      projects[index] = item;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CERTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  void addOrEditCert({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] as String?) ?? '',
    );
    final orgCtrl = TextEditingController(
      text: (existing?['org'] as String?) ?? '',
    );
    final dateCtrl = TextEditingController(
      text: (existing?['date'] as String?) ?? '',
    );
    final idCtrl = TextEditingController(
      text: (existing?['id'] as String?) ?? '',
    );

    showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(
                  index == null ? 'Add Certification' : 'Edit Certification',
                ),
                field(
                  'Certificate Name',
                  nameCtrl,
                  hint: 'e.g. AWS Solutions Architect',
                ),
                field(
                  'Issuing Organization',
                  orgCtrl,
                  hint: 'e.g. Amazon Web Services',
                ),
                field('Issue Date', dateCtrl, hint: 'e.g. May 2023'),
                field(
                  'Credential ID (optional)',
                  idCtrl,
                  hint: 'e.g. AWS-123456',
                ),
                const SizedBox(height: 24),
                saveBtn(() {
                  if (nameCtrl.text.isEmpty || orgCtrl.text.isEmpty) return;
                  final item = {
                    'name': nameCtrl.text,
                    'org': orgCtrl.text,
                    'date': dateCtrl.text,
                    'id': idCtrl.text,
                  };
                  setState(() {
                    if (index == null) {
                      certifications.add(item);
                    } else {
                      certifications[index] = item;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════════════════
  void addOrEditAchievement({Map<String, dynamic>? existing, int? index}) {
    final titleCtrl = TextEditingController(
      text: (existing?['title'] as String?) ?? '',
    );
    final descCtrl = TextEditingController(
      text: (existing?['desc'] as String?) ?? '',
    );
    final dateCtrl = TextEditingController(
      text: (existing?['date'] as String?) ?? '',
    );

    showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(
                  index == null ? 'Add Achievement' : 'Edit Achievement',
                ),
                field('Title', titleCtrl, hint: 'e.g. Hackathon Winner'),
                field(
                  'Description',
                  descCtrl,
                  hint: 'Describe your achievement…',
                  maxLines: 3,
                ),
                field('Date (optional)', dateCtrl, hint: 'e.g. Oct 2023'),
                const SizedBox(height: 24),
                saveBtn(() {
                  if (titleCtrl.text.isEmpty) return;
                  final item = {
                    'title': titleCtrl.text,
                    'desc': descCtrl.text,
                    'date': dateCtrl.text,
                  };
                  setState(() {
                    if (index == null) {
                      achievements.add(item);
                    } else {
                      achievements[index] = item;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Reusable field widget ────────────────────────────────────────────────
  Widget field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  // ─── Save button ──────────────────────────────────────────────────────────
  Widget saveBtn(VoidCallback onSave) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('Save', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // ─── Delete confirm ───────────────────────────────────────────────────────
  Future<void> confirmDelete(List<Map<String, dynamic>> list, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to remove this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) setState(() => list.removeAt(index));
  }

  Resume buildResumeFromForm() {
    final dateFmt = DateFormat('MMM yyyy');
    DateTime? tryParse(String? s) {
      if (s == null || s.isEmpty || s == 'Present') return null;
      try {
        return dateFmt.parse(s);
      } catch (_) {
        return DateTime.now();
      }
    }

    return Resume(
      id: _resumeId,
      userId: widget.resume?.userId ?? 'user',
      title: widget.resume?.title ?? 'My Resume',
      templateType: widget.resume?.templateType ?? widget.templateType,
      personalInfo: PersonalInfo(
        firstName: firstNameCtrl.text.isNotEmpty ? firstNameCtrl.text : 'Your',
        lastName: lastNameCtrl.text.isNotEmpty ? lastNameCtrl.text : 'Name',
        email: emailCtrl.text.isNotEmpty ? emailCtrl.text : 'email@example.com',
        phone: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
        location: locationCtrl.text.isNotEmpty ? locationCtrl.text : null,
        website: websiteCtrl.text.isNotEmpty ? websiteCtrl.text : null,
        summary: summaryCtrl.text.isNotEmpty ? summaryCtrl.text : null,
      ),
      education: educations.map((e) {
        final degree = (e['degree'] as String?) ?? '';
        final institution = (e['institution'] as String?) ?? '';
        final field = (e['field'] as String?) ?? '';
        final start = (e['start'] as String?) ?? '';
        final end = (e['end'] as String?) ?? '';
        final isCurrent = (e['current'] as bool?) ?? false;
        final grade = (e['grade'] as String?) ?? '';

        return Education(
          id: 'edu_${educations.indexOf(e)}',
          degree: degree,
          institution: institution,
          fieldOfStudy: field.isNotEmpty ? field : null,
          startDate: tryParse(start) ?? DateTime.now(),
          endDate: end == 'Present' ? null : tryParse(end),
          currentlyStudying: end == 'Present' || isCurrent,
          grade: grade.isNotEmpty ? grade : null,
        );
      }).toList(),
      experience: experiences.map((e) {
        final title = (e['title'] as String?) ?? '';
        final company = (e['company'] as String?) ?? '';
        final start = (e['start'] as String?) ?? '';
        final end = (e['end'] as String?) ?? '';
        final isCurrent = (e['current'] as bool?) ?? false;
        final location = (e['location'] as String?) ?? '';
        final desc = (e['desc'] as String?) ?? '';

        return Experience(
          id: 'exp_${experiences.indexOf(e)}',
          jobTitle: title,
          company: company,
          startDate: tryParse(start) ?? DateTime.now(),
          endDate: end == 'Present' ? null : tryParse(end),
          currentlyWorking: end == 'Present' || isCurrent,
          location: location.isNotEmpty ? location : null,
          description: desc.isNotEmpty ? desc : null,
        );
      }).toList(),
      skills: skills.map((s) {
        final name = (s['name'] as String?) ?? '';
        final category = (s['category'] as String?) ?? '';
        final level = (s['level'] as String?) ?? 'Intermediate';

        return Skill(
          id: 'sk_${skills.indexOf(s)}',
          name: name,
          category: category.isNotEmpty ? category : null,
          proficiency: level,
        );
      }).toList(),
      projects: projects.map((p) {
        final name = (p['name'] as String?) ?? '';
        final desc = (p['desc'] as String?) ?? '';
        final tech = (p['tech'] as String?) ?? '';
        final link = (p['link'] as String?) ?? '';

        return Project(
          id: 'proj_${projects.indexOf(p)}',
          name: name,
          description: desc,
          technologies: tech
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
          projectLink: link.isNotEmpty ? link : null,
        );
      }).toList(),
      certifications: certifications.map((c) {
        final name = (c['name'] as String?) ?? '';
        final org = (c['org'] as String?) ?? '';
        final date = (c['date'] as String?) ?? '';
        final id = (c['id'] as String?) ?? '';

        return Certification(
          id: 'cert_${certifications.indexOf(c)}',
          name: name,
          issuingOrganization: org,
          issueDate: tryParse(date) ?? DateTime.now(),
          credentialId: id.isNotEmpty ? id : null,
        );
      }).toList(),
      achievements: achievements.map((a) {
        final title = (a['title'] as String?) ?? '';
        final desc = (a['desc'] as String?) ?? '';

        return Achievement(
          id: 'ach_${achievements.indexOf(a)}',
          title: title,
          description: desc,
        );
      }).toList(),
      languages: languages.map((l) {
        final name = (l['name'] as String?) ?? '';
        final level = (l['level'] as String?) ?? 'Fluent';

        return Language(
          id: 'lang_${languages.indexOf(l)}',
          name: name,
          proficiency: level,
        );
      }).toList(),
      createdAt: widget.resume?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void showLivePreview() {
    final resume = buildResumeFromForm();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.preview_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Live Preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.12,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: buildTemplateRenderer(
                            widget.templateType,
                            resume,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop || _hasSavedOrAutoSaved) return;

        final newResume = buildResumeFromForm();
        if (widget.resume == null) {
          context.read<ResumeBloc>().add(CreateResumeEvent(newResume));
        } else {
          context.read<ResumeBloc>().add(UpdateResumeEvent(newResume));
        }
        context.read<ResumeBloc>().add(const LoadAllResumesEvent());
        _hasSavedOrAutoSaved = true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Resume Editor'),
          actions: [
            TextButton.icon(
              onPressed: () {
                final newResume = buildResumeFromForm();
                if (widget.resume == null) {
                  context.read<ResumeBloc>().add(CreateResumeEvent(newResume));
                } else {
                  context.read<ResumeBloc>().add(UpdateResumeEvent(newResume));
                }
                context.read<ResumeBloc>().add(const LoadAllResumesEvent());

                _hasSavedOrAutoSaved = true;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resume saved successfully!'),
                    backgroundColor: AppColors.accent,
                  ),
                );
                Navigator.pop(context); // Go back after saving
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: showLivePreview,
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.preview_rounded),
          label: const Text('Preview'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Personal Info ──────────────────────────────────────────────
              sectionCard(
                icon: Icons.person_outline,
                title: 'Personal Information',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: field(
                            'First Name',
                            firstNameCtrl,
                            hint: 'John',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: field('Last Name', lastNameCtrl, hint: 'Doe'),
                        ),
                      ],
                    ),
                    field('Email', emailCtrl, hint: 'john@example.com'),
                    Row(
                      children: [
                        Expanded(
                          child: field(
                            'Phone',
                            phoneCtrl,
                            hint: '+91 98765 43210',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: field(
                            'Location',
                            locationCtrl,
                            hint: 'Mumbai, India',
                          ),
                        ),
                      ],
                    ),
                    field(
                      'Website / LinkedIn',
                      websiteCtrl,
                      hint: 'https://yoursite.com',
                    ),
                    field(
                      'Professional Summary',
                      summaryCtrl,
                      hint: 'Brief intro about yourself…',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Education ─────────────────────────────────────────────────
              sectionHeader(
                icon: Icons.school_outlined,
                title: 'Education',
                subtitle: educations.isEmpty
                    ? 'Add your educational background'
                    : '${educations.length} entr${educations.length == 1 ? 'y' : 'ies'}',
                onAdd: () => addOrEditEducation(),
              ),
              ...educations.asMap().entries.map((e) {
                final value = e.value;
                final degree = (value['degree'] as String?) ?? '';
                final institution = (value['institution'] as String?) ?? '';
                final field = (value['field'] as String?) ?? '';
                final start = (value['start'] as String?) ?? '';
                final end = (value['end'] as String?) ?? '';

                return itemCard(
                  title: degree,
                  subtitle:
                      '$institution${field.isNotEmpty ? ' • $field' : ''}',
                  trailing: '$start – $end',
                  onEdit: () =>
                      addOrEditEducation(existing: value, index: e.key),
                  onDelete: () => confirmDelete(educations, e.key),
                );
              }),
              const SizedBox(height: 16),

              // ── Experience ────────────────────────────────────────────────
              sectionHeader(
                icon: Icons.work_outline,
                title: 'Experience',
                subtitle: experiences.isEmpty
                    ? 'Add your work experience'
                    : '${experiences.length} entr${experiences.length == 1 ? 'y' : 'ies'}',
                onAdd: () => addOrEditExperience(),
              ),
              ...experiences.asMap().entries.map((e) {
                final value = e.value;
                final title = (value['title'] as String?) ?? '';
                final company = (value['company'] as String?) ?? '';
                final location = (value['location'] as String?) ?? '';
                final start = (value['start'] as String?) ?? '';
                final end = (value['end'] as String?) ?? '';

                return itemCard(
                  title: title,
                  subtitle:
                      '$company${location.isNotEmpty ? ' • $location' : ''}',
                  trailing: '$start – $end',
                  onEdit: () =>
                      addOrEditExperience(existing: value, index: e.key),
                  onDelete: () => confirmDelete(experiences, e.key),
                );
              }),
              const SizedBox(height: 16),

              // ── Skills ────────────────────────────────────────────────────
              sectionHeader(
                icon: Icons.psychology_outlined,
                title: 'Skills',
                subtitle: skills.isEmpty
                    ? 'Add your skills'
                    : '${skills.length} skill${skills.length == 1 ? '' : 's'}',
                onAdd: () => addOrEditSkill(),
              ),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.asMap().entries.map((e) {
                    return GestureDetector(
                      onLongPress: () => confirmDelete(skills, e.key),
                      child: Chip(
                        label: Text(
                          '${e.value['name']} • ${e.value['level']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => confirmDelete(skills, e.key),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),

              // ── Projects ──────────────────────────────────────────────────
              sectionHeader(
                icon: Icons.folder_outlined,
                title: 'Projects',
                subtitle: projects.isEmpty
                    ? 'Add your projects'
                    : '${projects.length} project${projects.length == 1 ? '' : 's'}',
                onAdd: () => addOrEditProject(),
              ),
              ...projects.asMap().entries.map((e) {
                final value = e.value;
                final name = (value['name'] as String?) ?? '';
                final tech = (value['tech'] as String?) ?? '';
                final desc = (value['desc'] as String?) ?? '';

                return itemCard(
                  title: name,
                  subtitle: tech.isNotEmpty ? tech : desc,
                  onEdit: () => addOrEditProject(existing: value, index: e.key),
                  onDelete: () => confirmDelete(projects, e.key),
                );
              }),
              const SizedBox(height: 16),

              // ── Certifications ────────────────────────────────────────────
              sectionHeader(
                icon: Icons.verified_outlined,
                title: 'Certifications',
                subtitle: certifications.isEmpty
                    ? 'Add certifications'
                    : '${certifications.length} certification${certifications.length == 1 ? '' : 's'}',
                onAdd: () => addOrEditCert(),
              ),
              ...certifications.asMap().entries.map((e) {
                final value = e.value;
                final name = (value['name'] as String?) ?? '';
                final org = (value['org'] as String?) ?? '';
                final date = (value['date'] as String?) ?? '';

                return itemCard(
                  title: name,
                  subtitle: org,
                  trailing: date,
                  onEdit: () => addOrEditCert(existing: value, index: e.key),
                  onDelete: () => confirmDelete(certifications, e.key),
                );
              }),
              const SizedBox(height: 16),

              // ── Achievements ──────────────────────────────────────────────
              sectionHeader(
                icon: Icons.emoji_events_outlined,
                title: 'Achievements',
                subtitle: achievements.isEmpty
                    ? 'Add your achievements'
                    : '${achievements.length} achievement${achievements.length == 1 ? '' : 's'}',
                onAdd: () => addOrEditAchievement(),
              ),
              ...achievements.asMap().entries.map((e) {
                final value = e.value;
                final title = (value['title'] as String?) ?? '';
                final desc = (value['desc'] as String?) ?? '';
                final date = (value['date'] as String?) ?? '';

                return itemCard(
                  title: title,
                  subtitle: desc,
                  trailing: date.isNotEmpty ? date : null,
                  onEdit: () =>
                      addOrEditAchievement(existing: value, index: e.key),
                  onDelete: () => confirmDelete(achievements, e.key),
                );
              }),
              const SizedBox(height: 16),

              // ── Languages ───────────────────────────────────────────────
              sectionHeader(
                icon: Icons.language_outlined,
                title: 'Languages',
                subtitle: languages.isEmpty
                    ? 'Add your languages'
                    : '${languages.length} language${languages.length == 1 ? '' : 's'}',
                onAdd: () => addOrEditLanguage(),
              ),
              ...languages.asMap().entries.map((e) {
                final value = e.value;
                final name = (value['name'] as String?) ?? '';
                final level = (value['level'] as String?) ?? '';

                return itemCard(
                  title: name,
                  subtitle: 'Proficiency: $level',
                  onEdit: () =>
                      addOrEditLanguage(existing: value, index: e.key),
                  onDelete: () => confirmDelete(languages, e.key),
                );
              }),

              const SizedBox(height: 32),

              // ── Analyze button ────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.atsAnalysis,
                    arguments: {
                      'firstName': firstNameCtrl.text,
                      'skills': skills.map((s) => s['name']).toList(),
                      'experience': experiences.length,
                    },
                  );
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Analyze ATS Score'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Expandable section card ──────────────────────────────────────────────
  Widget sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
