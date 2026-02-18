// Resume Entity
class Resume {
  final String id;
  final String userId;
  final String title;
  final PersonalInfo? personalInfo;
  final List<Education> education;
  final List<Skill> skills;
  final List<Experience> experience;
  final List<Project> projects;
  final List<Certification> certifications;
  final List<Achievement> achievements;
  final List<Language> languages;
  final SocialLinks? socialLinks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? atsScore;

  const Resume({
    required this.id,
    required this.userId,
    required this.title,
    this.personalInfo,
    this.education = const [],
    this.skills = const [],
    this.experience = const [],
    this.projects = const [],
    this.certifications = const [],
    this.achievements = const [],
    this.languages = const [],
    this.socialLinks,
    required this.createdAt,
    required this.updatedAt,
    this.atsScore,
  });

  Resume copyWith({
    String? id,
    String? userId,
    String? title,
    PersonalInfo? personalInfo,
    List<Education>? education,
    List<Skill>? skills,
    List<Experience>? experience,
    List<Project>? projects,
    List<Certification>? certifications,
    List<Achievement>? achievements,
    List<Language>? languages,
    SocialLinks? socialLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? atsScore,
  }) {
    return Resume(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      personalInfo: personalInfo ?? this.personalInfo,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      achievements: achievements ?? this.achievements,
      languages: languages ?? this.languages,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      atsScore: atsScore ?? this.atsScore,
    );
  }
}

// Personal Info Entity
class PersonalInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? location;
  final String? website;
  final String? summary;

  const PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.location,
    this.website,
    this.summary,
  });

  String get fullName => '$firstName $lastName';
}

// Education Entity
class Education {
  final String id;
  final String degree;
  final String institution;
  final String? fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final String? grade;
  final bool currentlyStudying;
  final String? description;

  const Education({
    required this.id,
    required this.degree,
    required this.institution,
    this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.grade,
    this.currentlyStudying = false,
    this.description,
  });
}

// Skill Entity
class Skill {
  final String id;
  final String name;
  final String? category;
  final String? proficiency; // Beginner, Intermediate, Advanced, Expert

  const Skill({
    required this.id,
    required this.name,
    this.category,
    this.proficiency,
  });
}

// Experience Entity
class Experience {
  final String id;
  final String jobTitle;
  final String company;
  final String? employmentType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool currentlyWorking;
  final String? location;
  final String? description;
  final List<String> responsibilities;

  const Experience({
    required this.id,
    required this.jobTitle,
    required this.company,
    this.employmentType,
    required this.startDate,
    this.endDate,
    this.currentlyWorking = false,
    this.location,
    this.description,
    this.responsibilities = const [],
  });
}

// Project Entity
class Project {
  final String id;
  final String name;
  final String description;
  final List<String> technologies;
  final String? projectLink;
  final DateTime? startDate;
  final DateTime? endDate;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    this.technologies = const [],
    this.projectLink,
    this.startDate,
    this.endDate,
  });
}

// Certification Entity
class Certification {
  final String id;
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;

  const Certification({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
  });
}

// Achievement Entity
class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime? date;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.date,
  });
}

// Language Entity
class Language {
  final String id;
  final String name;
  final String proficiency; // Native, Fluent, Advanced, Intermediate, Basic

  const Language({
    required this.id,
    required this.name,
    required this.proficiency,
  });
}

// Social Links Entity
class SocialLinks {
  final String? linkedin;
  final String? github;
  final String? twitter;
  final String? portfolio;
  final Map<String, String> otherLinks;

  const SocialLinks({
    this.linkedin,
    this.github,
    this.twitter,
    this.portfolio,
    this.otherLinks = const {},
  });
}
