import '../../domain/entities/resume.dart';

// Resume Model
class ResumeModel extends Resume {
  const ResumeModel({
    required super.id,
    required super.userId,
    required super.title,
    super.personalInfo,
    super.education,
    super.skills,
    super.experience,
    super.projects,
    super.certifications,
    super.achievements,
    super.languages,
    super.socialLinks,
    required super.createdAt,
    required super.updatedAt,
    super.atsScore,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      personalInfo: json['personalInfo'] != null
          ? PersonalInfoModel.fromJson(json['personalInfo'])
          : null,
      education:
          (json['education'] as List<dynamic>?)
              ?.map((e) => EducationModel.fromJson(e))
              .toList() ??
          [],
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => SkillModel.fromJson(e))
              .toList() ??
          [],
      experience:
          (json['experience'] as List<dynamic>?)
              ?.map((e) => ExperienceModel.fromJson(e))
              .toList() ??
          [],
      projects:
          (json['projects'] as List<dynamic>?)
              ?.map((e) => ProjectModel.fromJson(e))
              .toList() ??
          [],
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => CertificationModel.fromJson(e))
              .toList() ??
          [],
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => AchievementModel.fromJson(e))
              .toList() ??
          [],
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => LanguageModel.fromJson(e))
              .toList() ??
          [],
      socialLinks: json['socialLinks'] != null
          ? SocialLinksModel.fromJson(json['socialLinks'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      atsScore: json['atsScore'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'personalInfo': personalInfo != null
          ? PersonalInfoModel.fromEntity(personalInfo!).toJson()
          : null,
      'education': education
          .map((e) => EducationModel.fromEntity(e).toJson())
          .toList(),
      'skills': skills.map((e) => SkillModel.fromEntity(e).toJson()).toList(),
      'experience': experience
          .map((e) => ExperienceModel.fromEntity(e).toJson())
          .toList(),
      'projects': projects
          .map((e) => ProjectModel.fromEntity(e).toJson())
          .toList(),
      'certifications': certifications
          .map((e) => CertificationModel.fromEntity(e).toJson())
          .toList(),
      'achievements': achievements
          .map((e) => AchievementModel.fromEntity(e).toJson())
          .toList(),
      'languages': languages
          .map((e) => LanguageModel.fromEntity(e).toJson())
          .toList(),
      'socialLinks': socialLinks != null
          ? SocialLinksModel.fromEntity(socialLinks!).toJson()
          : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'atsScore': atsScore,
    };
  }

  static ResumeModel fromEntity(Resume resume) {
    return ResumeModel(
      id: resume.id,
      userId: resume.userId,
      title: resume.title,
      personalInfo: resume.personalInfo,
      education: resume.education,
      skills: resume.skills,
      experience: resume.experience,
      projects: resume.projects,
      certifications: resume.certifications,
      achievements: resume.achievements,
      languages: resume.languages,
      socialLinks: resume.socialLinks,
      createdAt: resume.createdAt,
      updatedAt: resume.updatedAt,
      atsScore: resume.atsScore,
    );
  }
}

// Personal Info Model
class PersonalInfoModel extends PersonalInfo {
  const PersonalInfoModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.location,
    super.website,
    super.summary,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'location': location,
      'website': website,
      'summary': summary,
    };
  }

  static PersonalInfoModel fromEntity(PersonalInfo entity) {
    return PersonalInfoModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phone: entity.phone,
      location: entity.location,
      website: entity.website,
      summary: entity.summary,
    );
  }
}

// Education Model
class EducationModel extends Education {
  const EducationModel({
    required super.id,
    required super.degree,
    required super.institution,
    super.fieldOfStudy,
    required super.startDate,
    super.endDate,
    super.grade,
    super.currentlyStudying,
    super.description,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] as String,
      degree: json['degree'] as String,
      institution: json['institution'] as String,
      fieldOfStudy: json['fieldOfStudy'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      grade: json['grade'] as String?,
      currentlyStudying: json['currentlyStudying'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'fieldOfStudy': fieldOfStudy,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'grade': grade,
      'currentlyStudying': currentlyStudying,
      'description': description,
    };
  }

  static EducationModel fromEntity(Education entity) {
    return EducationModel(
      id: entity.id,
      degree: entity.degree,
      institution: entity.institution,
      fieldOfStudy: entity.fieldOfStudy,
      startDate: entity.startDate,
      endDate: entity.endDate,
      grade: entity.grade,
      currentlyStudying: entity.currentlyStudying,
      description: entity.description,
    );
  }
}

// Skill Model
class SkillModel extends Skill {
  const SkillModel({
    required super.id,
    required super.name,
    super.category,
    super.proficiency,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      proficiency: json['proficiency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'proficiency': proficiency,
    };
  }

  static SkillModel fromEntity(Skill entity) {
    return SkillModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      proficiency: entity.proficiency,
    );
  }
}

// Experience Model
class ExperienceModel extends Experience {
  const ExperienceModel({
    required super.id,
    required super.jobTitle,
    required super.company,
    super.employmentType,
    required super.startDate,
    super.endDate,
    super.currentlyWorking,
    super.location,
    super.description,
    super.responsibilities,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as String,
      jobTitle: json['jobTitle'] as String,
      company: json['company'] as String,
      employmentType: json['employmentType'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      currentlyWorking: json['currentlyWorking'] as bool? ?? false,
      location: json['location'] as String?,
      description: json['description'] as String?,
      responsibilities:
          (json['responsibilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'company': company,
      'employmentType': employmentType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'currentlyWorking': currentlyWorking,
      'location': location,
      'description': description,
      'responsibilities': responsibilities,
    };
  }

  static ExperienceModel fromEntity(Experience entity) {
    return ExperienceModel(
      id: entity.id,
      jobTitle: entity.jobTitle,
      company: entity.company,
      employmentType: entity.employmentType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      currentlyWorking: entity.currentlyWorking,
      location: entity.location,
      description: entity.description,
      responsibilities: entity.responsibilities,
    );
  }
}

// Project Model
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    super.technologies,
    super.projectLink,
    super.startDate,
    super.endDate,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      technologies:
          (json['technologies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      projectLink: json['projectLink'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'projectLink': projectLink,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  static ProjectModel fromEntity(Project entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      technologies: entity.technologies,
      projectLink: entity.projectLink,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }
}

// Certification Model
class CertificationModel extends Certification {
  const CertificationModel({
    required super.id,
    required super.name,
    required super.issuingOrganization,
    required super.issueDate,
    super.expiryDate,
    super.credentialId,
    super.credentialUrl,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      issuingOrganization: json['issuingOrganization'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      credentialId: json['credentialId'] as String?,
      credentialUrl: json['credentialUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuingOrganization': issuingOrganization,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
    };
  }

  static CertificationModel fromEntity(Certification entity) {
    return CertificationModel(
      id: entity.id,
      name: entity.name,
      issuingOrganization: entity.issuingOrganization,
      issueDate: entity.issueDate,
      expiryDate: entity.expiryDate,
      credentialId: entity.credentialId,
      credentialUrl: entity.credentialUrl,
    );
  }
}

// Achievement Model
class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.title,
    required super.description,
    super.date,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),
    };
  }

  static AchievementModel fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      date: entity.date,
    );
  }
}

// Language Model
class LanguageModel extends Language {
  const LanguageModel({
    required super.id,
    required super.name,
    required super.proficiency,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      proficiency: json['proficiency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'proficiency': proficiency};
  }

  static LanguageModel fromEntity(Language entity) {
    return LanguageModel(
      id: entity.id,
      name: entity.name,
      proficiency: entity.proficiency,
    );
  }
}

// Social Links Model
class SocialLinksModel extends SocialLinks {
  const SocialLinksModel({
    super.linkedin,
    super.github,
    super.twitter,
    super.portfolio,
    super.otherLinks,
  });

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) {
    return SocialLinksModel(
      linkedin: json['linkedin'] as String?,
      github: json['github'] as String?,
      twitter: json['twitter'] as String?,
      portfolio: json['portfolio'] as String?,
      otherLinks:
          (json['otherLinks'] as Map<String, dynamic>?)
              ?.cast<String, String>() ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'linkedin': linkedin,
      'github': github,
      'twitter': twitter,
      'portfolio': portfolio,
      'otherLinks': otherLinks,
    };
  }

  static SocialLinksModel fromEntity(SocialLinks entity) {
    return SocialLinksModel(
      linkedin: entity.linkedin,
      github: entity.github,
      twitter: entity.twitter,
      portfolio: entity.portfolio,
      otherLinks: entity.otherLinks,
    );
  }
}
