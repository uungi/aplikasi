class UserInput {
  String name;
  String position;
  List<String> experiences;
  List<String> education;
  List<String> skills;
  String contact;
  String company;
  String additional;
  String template;

  UserInput({
    required this.name,
    required this.position,
    required this.experiences,
    required this.education,
    required this.skills,
    required this.contact,
    this.company = "",
    this.additional = "",
    this.template = "standard",
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'experiences': experiences,
      'education': education,
      'skills': skills,
      'contact': contact,
      'company': company,
      'additional': additional,
      'template': template,
    };
  }

  factory UserInput.fromMap(Map<String, dynamic> map) {
    return UserInput(
      name: map['name'] ?? '',
      position: map['position'] ?? '',
      experiences: List<String>.from(map['experiences'] ?? []),
      education: List<String>.from(map['education'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      contact: map['contact'] ?? '',
      company: map['company'] ?? '',
      additional: map['additional'] ?? '',
      template: map['template'] ?? 'standard',
    );
  }
}
