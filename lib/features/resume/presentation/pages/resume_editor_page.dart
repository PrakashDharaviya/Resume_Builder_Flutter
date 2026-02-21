import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class ResumeEditorPage extends StatefulWidget {
  const ResumeEditorPage({super.key});

  @override
  State<ResumeEditorPage> createState() => _ResumeEditorPageState();
}

class _ResumeEditorPageState extends State<ResumeEditorPage> {
  // Personal Info controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  // Section data lists
  final List<Map<String, dynamic>> _educations = [];
  final List<Map<String, dynamic>> _experiences = [];
  final List<Map<String, dynamic>> _skills = [];
  final List<Map<String, dynamic>> _languages = [];
  final List<Map<String, dynamic>> _projects = [];
  final List<Map<String, dynamic>> _certifications = [];
  final List<Map<String, dynamic>> _achievements = [];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  // ─── Generic section card ────────────────────────────────────────────────
  Widget _sectionHeader({
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
  Widget _itemCard({
    required String title,
    required String subtitle,
    String? trailing,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
  Future<void> _showSheet(Widget form) async {
    await showModalBottomSheet(
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
  Widget _sheetHandle(String title) {
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
  void _addOrEditEducation({Map<String, dynamic>? existing, int? index}) {
    final degreeCtrl = TextEditingController(text: existing?['degree'] ?? '');
    final institutionCtrl = TextEditingController(
      text: existing?['institution'] ?? '',
    );
    final fieldCtrl = TextEditingController(text: existing?['field'] ?? '');
    final gradeCtrl = TextEditingController(text: existing?['grade'] ?? '');
    final startCtrl = TextEditingController(text: existing?['start'] ?? '');
    final endCtrl = TextEditingController(text: existing?['end'] ?? '');
    bool current = existing?['current'] ?? false;

    _showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(
                  index == null ? 'Add Education' : 'Edit Education',
                ),
                _field(
                  'Degree / Qualification',
                  degreeCtrl,
                  hint: 'e.g. Bachelor of Science',
                ),
                _field(
                  'Institution',
                  institutionCtrl,
                  hint: 'e.g. Stanford University',
                ),
                _field(
                  'Field of Study',
                  fieldCtrl,
                  hint: 'e.g. Computer Science',
                ),
                _field('Grade / CGPA', gradeCtrl, hint: 'e.g. 3.8 GPA'),
                Row(
                  children: [
                    Expanded(
                      child: _field('Start Year', startCtrl, hint: '2020'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
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
                _saveBtn(() {
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
                      _educations.add(item);
                    } else {
                      _educations[index] = item;
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
  void _addOrEditExperience({Map<String, dynamic>? existing, int? index}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final companyCtrl = TextEditingController(text: existing?['company'] ?? '');
    final locationCtrl = TextEditingController(
      text: existing?['location'] ?? '',
    );
    final startCtrl = TextEditingController(text: existing?['start'] ?? '');
    final endCtrl = TextEditingController(text: existing?['end'] ?? '');
    final descCtrl = TextEditingController(text: existing?['desc'] ?? '');
    bool current = existing?['current'] ?? false;

    _showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(
                  index == null ? 'Add Experience' : 'Edit Experience',
                ),
                _field('Job Title', titleCtrl, hint: 'e.g. Software Engineer'),
                _field('Company', companyCtrl, hint: 'e.g. Google'),
                _field(
                  'Location',
                  locationCtrl,
                  hint: 'e.g. San Francisco, CA (or Remote)',
                ),
                Row(
                  children: [
                    Expanded(
                      child: _field('Start', startCtrl, hint: 'Jan 2022'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        'End',
                        endCtrl,
                        hint: 'Dec 2024',
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
                _field(
                  'Description / Responsibilities',
                  descCtrl,
                  hint: 'Describe your role and achievements…',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _saveBtn(() {
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
                      _experiences.add(item);
                    } else {
                      _experiences[index] = item;
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
  void _addOrEditSkill({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final categoryCtrl = TextEditingController(
      text: existing?['category'] ?? '',
    );
    String level = existing?['level'] ?? 'Intermediate';

    _showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(index == null ? 'Add Skill' : 'Edit Skill'),
                _field('Skill Name', nameCtrl, hint: 'e.g. Flutter'),
                _field(
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
                _saveBtn(() {
                  if (nameCtrl.text.isEmpty) return;
                  final item = {
                    'name': nameCtrl.text,
                    'category': categoryCtrl.text,
                    'level': level,
                  };
                  setState(() {
                    if (index == null) {
                      _skills.add(item);
                    } else {
                      _skills[index] = item;
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
  void _addOrEditLanguage({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    String level = existing?['level'] ?? 'Fluent';

    _showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(index == null ? 'Add Language' : 'Edit Language'),
                _field('Language', nameCtrl, hint: 'e.g. English'),
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
                _saveBtn(() {
                  if (nameCtrl.text.isEmpty) return;
                  final item = {'name': nameCtrl.text, 'level': level};
                  setState(() {
                    if (index == null) {
                      _languages.add(item);
                    } else {
                      _languages[index] = item;
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
  void _addOrEditProject({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final descCtrl = TextEditingController(text: existing?['desc'] ?? '');
    final techCtrl = TextEditingController(text: existing?['tech'] ?? '');
    final linkCtrl = TextEditingController(text: existing?['link'] ?? '');

    _showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(index == null ? 'Add Project' : 'Edit Project'),
                _field('Project Name', nameCtrl, hint: 'e.g. ResumeIQ App'),
                _field(
                  'Description',
                  descCtrl,
                  hint: 'What does the project do?',
                  maxLines: 3,
                ),
                _field(
                  'Technologies Used',
                  techCtrl,
                  hint: 'e.g. Flutter, Firebase, Node.js',
                ),
                _field(
                  'Project Link (optional)',
                  linkCtrl,
                  hint: 'https://github.com/...',
                ),
                const SizedBox(height: 24),
                _saveBtn(() {
                  if (nameCtrl.text.isEmpty) return;
                  final item = {
                    'name': nameCtrl.text,
                    'desc': descCtrl.text,
                    'tech': techCtrl.text,
                    'link': linkCtrl.text,
                  };
                  setState(() {
                    if (index == null) {
                      _projects.add(item);
                    } else {
                      _projects[index] = item;
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
  void _addOrEditCert({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final orgCtrl = TextEditingController(text: existing?['org'] ?? '');
    final dateCtrl = TextEditingController(text: existing?['date'] ?? '');
    final idCtrl = TextEditingController(text: existing?['id'] ?? '');

    _showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(
                  index == null ? 'Add Certification' : 'Edit Certification',
                ),
                _field(
                  'Certificate Name',
                  nameCtrl,
                  hint: 'e.g. AWS Solutions Architect',
                ),
                _field(
                  'Issuing Organization',
                  orgCtrl,
                  hint: 'e.g. Amazon Web Services',
                ),
                _field('Issue Date', dateCtrl, hint: 'e.g. May 2023'),
                _field(
                  'Credential ID (optional)',
                  idCtrl,
                  hint: 'e.g. AWS-123456',
                ),
                const SizedBox(height: 24),
                _saveBtn(() {
                  if (nameCtrl.text.isEmpty || orgCtrl.text.isEmpty) return;
                  final item = {
                    'name': nameCtrl.text,
                    'org': orgCtrl.text,
                    'date': dateCtrl.text,
                    'id': idCtrl.text,
                  };
                  setState(() {
                    if (index == null) {
                      _certifications.add(item);
                    } else {
                      _certifications[index] = item;
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
  void _addOrEditAchievement({Map<String, dynamic>? existing, int? index}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final descCtrl = TextEditingController(text: existing?['desc'] ?? '');
    final dateCtrl = TextEditingController(text: existing?['date'] ?? '');

    _showSheet(
      StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(
                  index == null ? 'Add Achievement' : 'Edit Achievement',
                ),
                _field('Title', titleCtrl, hint: 'e.g. Hackathon Winner'),
                _field(
                  'Description',
                  descCtrl,
                  hint: 'Describe your achievement…',
                  maxLines: 3,
                ),
                _field('Date (optional)', dateCtrl, hint: 'e.g. Oct 2023'),
                const SizedBox(height: 24),
                _saveBtn(() {
                  if (titleCtrl.text.isEmpty) return;
                  final item = {
                    'title': titleCtrl.text,
                    'desc': descCtrl.text,
                    'date': dateCtrl.text,
                  };
                  setState(() {
                    if (index == null) {
                      _achievements.add(item);
                    } else {
                      _achievements[index] = item;
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
  Widget _field(
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
  Widget _saveBtn(VoidCallback onSave) {
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
  Future<void> _confirmDelete(
    List<Map<String, dynamic>> list,
    int index,
  ) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Resume Editor'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resume saved successfully!'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Personal Info ──────────────────────────────────────────────
            _sectionCard(
              icon: Icons.person_outline,
              title: 'Personal Information',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          'First Name',
                          _firstNameCtrl,
                          hint: 'John',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field('Last Name', _lastNameCtrl, hint: 'Doe'),
                      ),
                    ],
                  ),
                  _field('Email', _emailCtrl, hint: 'john@example.com'),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          'Phone',
                          _phoneCtrl,
                          hint: '+91 98765 43210',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          'Location',
                          _locationCtrl,
                          hint: 'Mumbai, India',
                        ),
                      ),
                    ],
                  ),
                  _field(
                    'Website / LinkedIn',
                    _websiteCtrl,
                    hint: 'https://yoursite.com',
                  ),
                  _field(
                    'Professional Summary',
                    _summaryCtrl,
                    hint: 'Brief intro about yourself…',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Education ─────────────────────────────────────────────────
            _sectionHeader(
              icon: Icons.school_outlined,
              title: 'Education',
              subtitle: _educations.isEmpty
                  ? 'Add your educational background'
                  : '${_educations.length} entr${_educations.length == 1 ? 'y' : 'ies'}',
              onAdd: () => _addOrEditEducation(),
            ),
            ..._educations.asMap().entries.map(
              (e) => _itemCard(
                title: e.value['degree'],
                subtitle:
                    '${e.value['institution']}${e.value['field'].isNotEmpty ? ' • ${e.value['field']}' : ''}',
                trailing: '${e.value['start']} – ${e.value['end']}',
                onEdit: () =>
                    _addOrEditEducation(existing: e.value, index: e.key),
                onDelete: () => _confirmDelete(_educations, e.key),
              ),
            ),
            const SizedBox(height: 16),

            // ── Experience ────────────────────────────────────────────────
            _sectionHeader(
              icon: Icons.work_outline,
              title: 'Experience',
              subtitle: _experiences.isEmpty
                  ? 'Add your work experience'
                  : '${_experiences.length} entr${_experiences.length == 1 ? 'y' : 'ies'}',
              onAdd: () => _addOrEditExperience(),
            ),
            ..._experiences.asMap().entries.map(
              (e) => _itemCard(
                title: e.value['title'],
                subtitle:
                    '${e.value['company']}${e.value['location'].isNotEmpty ? ' • ${e.value['location']}' : ''}',
                trailing: '${e.value['start']} – ${e.value['end']}',
                onEdit: () =>
                    _addOrEditExperience(existing: e.value, index: e.key),
                onDelete: () => _confirmDelete(_experiences, e.key),
              ),
            ),
            const SizedBox(height: 16),

            // ── Skills ────────────────────────────────────────────────────
            _sectionHeader(
              icon: Icons.psychology_outlined,
              title: 'Skills',
              subtitle: _skills.isEmpty
                  ? 'Add your skills'
                  : '${_skills.length} skill${_skills.length == 1 ? '' : 's'}',
              onAdd: () => _addOrEditSkill(),
            ),
            if (_skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.asMap().entries.map((e) {
                  return GestureDetector(
                    onLongPress: () => _confirmDelete(_skills, e.key),
                    child: Chip(
                      label: Text(
                        '${e.value['name']} • ${e.value['level']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _confirmDelete(_skills, e.key),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // ── Projects ──────────────────────────────────────────────────
            _sectionHeader(
              icon: Icons.folder_outlined,
              title: 'Projects',
              subtitle: _projects.isEmpty
                  ? 'Add your projects'
                  : '${_projects.length} project${_projects.length == 1 ? '' : 's'}',
              onAdd: () => _addOrEditProject(),
            ),
            ..._projects.asMap().entries.map(
              (e) => _itemCard(
                title: e.value['name'],
                subtitle: e.value['tech'].isNotEmpty
                    ? e.value['tech']
                    : e.value['desc'],
                onEdit: () =>
                    _addOrEditProject(existing: e.value, index: e.key),
                onDelete: () => _confirmDelete(_projects, e.key),
              ),
            ),
            const SizedBox(height: 16),

            // ── Certifications ────────────────────────────────────────────
            _sectionHeader(
              icon: Icons.verified_outlined,
              title: 'Certifications',
              subtitle: _certifications.isEmpty
                  ? 'Add certifications'
                  : '${_certifications.length} certification${_certifications.length == 1 ? '' : 's'}',
              onAdd: () => _addOrEditCert(),
            ),
            ..._certifications.asMap().entries.map(
              (e) => _itemCard(
                title: e.value['name'],
                subtitle: e.value['org'],
                trailing: e.value['date'],
                onEdit: () => _addOrEditCert(existing: e.value, index: e.key),
                onDelete: () => _confirmDelete(_certifications, e.key),
              ),
            ),
            const SizedBox(height: 16),

            // ── Achievements ──────────────────────────────────────────────
            _sectionHeader(
              icon: Icons.emoji_events_outlined,
              title: 'Achievements',
              subtitle: _achievements.isEmpty
                  ? 'Add your achievements'
                  : '${_achievements.length} achievement${_achievements.length == 1 ? '' : 's'}',
              onAdd: () => _addOrEditAchievement(),
            ),
            ..._achievements.asMap().entries.map(
              (e) => _itemCard(
                title: e.value['title'],
                subtitle: e.value['desc'],
                trailing: e.value['date'].isNotEmpty ? e.value['date'] : null,
                onEdit: () =>
                    _addOrEditAchievement(existing: e.value, index: e.key),
                onDelete: () => _confirmDelete(_achievements, e.key),
              ),
            ),
            const SizedBox(height: 16),

            // ── Languages ───────────────────────────────────────────────
            _sectionHeader(
              icon: Icons.language_outlined,
              title: 'Languages',
              subtitle: _languages.isEmpty
                  ? 'Add your languages'
                  : '${_languages.length} language${_languages.length == 1 ? '' : 's'}',
              onAdd: () => _addOrEditLanguage(),
            ),
            ..._languages.asMap().entries.map(
              (e) => _itemCard(
                title: e.value['name'],
                subtitle: 'Proficiency: ${e.value['level']}',
                onEdit: () =>
                    _addOrEditLanguage(existing: e.value, index: e.key),
                onDelete: () => _confirmDelete(_languages, e.key),
              ),
            ),

            const SizedBox(height: 32),

            // ── Analyze button ────────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.atsAnalysis,
                  arguments: {
                    'firstName': _firstNameCtrl.text,
                    'skills': _skills.map((s) => s['name']).toList(),
                    'experience': _experiences.length,
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
    );
  }

  // ─── Expandable section card ──────────────────────────────────────────────
  Widget _sectionCard({
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
