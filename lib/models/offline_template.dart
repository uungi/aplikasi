import 'dart:convert';

class OfflineTemplate {
  final String id;
  final String name;
  final String type; // 'resume' atau 'coverLetter'
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfflineTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  OfflineTemplate copyWith({
    String? id,
    String? name,
    String? type,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfflineTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OfflineTemplate.fromMap(Map<String, dynamic> map) {
    return OfflineTemplate(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory OfflineTemplate.fromJson(String source) => OfflineTemplate.fromMap(json.decode(source));

  static List<OfflineTemplate> getDefaultTemplates() {
    final now = DateTime.now();
    return [
      OfflineTemplate(
        id: 'offline_resume_professional',
        name: 'Professional Resume',
        type: 'resume',
        content: '''
# PROFESSIONAL RESUME TEMPLATE

## PERSONAL INFORMATION
[Full Name]
[Position]
[Contact Information]

## PROFESSIONAL SUMMARY
A brief summary of your professional background and key strengths.

## WORK EXPERIENCE
### [Job Title] | [Company Name] | [Dates]
- Key responsibility or achievement
- Key responsibility or achievement
- Key responsibility or achievement

### [Job Title] | [Company Name] | [Dates]
- Key responsibility or achievement
- Key responsibility or achievement
- Key responsibility or achievement

## EDUCATION
### [Degree] | [Institution] | [Dates]
- Relevant coursework or achievements
- GPA if applicable

## SKILLS
- Skill 1
- Skill 2
- Skill 3
- Skill 4
- Skill 5

## ADDITIONAL INFORMATION
Languages, certifications, or other relevant information.
''',
        createdAt: now,
        updatedAt: now,
      ),
      OfflineTemplate(
        id: 'offline_coverletter_professional',
        name: 'Professional Cover Letter',
        type: 'coverLetter',
        content: '''
# PROFESSIONAL COVER LETTER TEMPLATE

[Your Name]
[Your Address]
[City, State ZIP Code]
[Your Email]
[Your Phone Number]
[Date]

[Recipient's Name]
[Title]
[Company Name]
[Address]
[City, State ZIP Code]

Dear [Recipient's Name],

## INTRODUCTION
I am writing to express my interest in the [Position] role at [Company Name]. With my background in [relevant experience/skills], I am confident in my ability to contribute effectively to your team.

## BODY PARAGRAPH 1
In my current/previous role as [Job Title] at [Company], I have developed and refined my skills in [relevant skills]. [Specific achievement or responsibility that relates to the job you're applying for].

## BODY PARAGRAPH 2
I am particularly drawn to [Company Name] because of [specific reason, such as company values, projects, reputation]. I believe that my experience in [relevant experience] aligns perfectly with what you're looking for in a [Position].

## CLOSING
Thank you for considering my application. I am excited about the opportunity to join [Company Name] and contribute to [specific goal or project]. I look forward to discussing how my skills and experiences can benefit your team.

Sincerely,
[Your Name]
''',
        createdAt: now,
        updatedAt: now,
      ),
      OfflineTemplate(
        id: 'offline_resume_creative',
        name: 'Creative Resume',
        type: 'resume',
        content: '''
# CREATIVE RESUME TEMPLATE

## [YOUR NAME]
### [Your Position/Title]
[Contact Information]

## ABOUT ME
A creative and engaging summary that showcases your personality and passion.

## MY JOURNEY
### [Company/Project] | [Dates]
*[Role/Title]*
- Creative achievement or contribution
- Creative achievement or contribution
- Creative achievement or contribution

### [Company/Project] | [Dates]
*[Role/Title]*
- Creative achievement or contribution
- Creative achievement or contribution
- Creative achievement or contribution

## EDUCATION & TRAINING
### [Institution] | [Dates]
*[Degree/Program]*
Notable projects or achievements

## SKILLS & EXPERTISE
- Creative Skill 1
- Creative Skill 2
- Creative Skill 3
- Technical Skill 1
- Technical Skill 2

## PORTFOLIO HIGHLIGHTS
Brief descriptions of key projects or works

## INTERESTS & PASSIONS
What drives and inspires you outside of work
''',
        createdAt: now,
        updatedAt: now,
      ),
      OfflineTemplate(
        id: 'offline_coverletter_creative',
        name: 'Creative Cover Letter',
        type: 'coverLetter',
        content: '''
# CREATIVE COVER LETTER TEMPLATE

[Your Name]
[Your Contact Information]
[Portfolio/Website if applicable]
[Date]

[Recipient's Name]
[Company Name]

Dear [Recipient's Name],

## OPENING HOOK
An engaging opening that captures attention and shows your personality. Perhaps a brief story or an interesting fact about why you're passionate about this opportunity.

## YOUR STORY
I've spent [time period] developing my skills in [relevant creative fields], with a particular focus on [specific area of expertise]. My journey through [relevant experience] has equipped me with a unique perspective that I'm excited to bring to [Company Name].

## WHY THIS OPPORTUNITY
What specifically excites you about this role and company? How does it align with your creative vision and career aspirations?

## WHY YOU'RE THE RIGHT FIT
How your specific creative experiences and achievements make you uniquely qualified for this position. Include a brief mention of a relevant project or achievement that demonstrates your capabilities.

## CLOSING
An enthusiastic closing that expresses your excitement about the possibility of collaboration and invites further conversation.

Creatively yours,
[Your Name]
''',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
