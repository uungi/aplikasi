import 'package:flutter/material.dart';

class ResumeTemplate {
  final String id;
  final String name;
  final String description;
  final String previewImage;
  final Color primaryColor;
  final Color accentColor;
  final bool isPremium;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.primaryColor,
    required this.accentColor,
    this.isPremium = false,
  });
}

class ResumeTemplates {
  static const standard = ResumeTemplate(
    id: 'standard',
    name: 'Standar',
    description: 'Template profesional yang cocok untuk semua jenis pekerjaan',
    previewImage: 'assets/images/templates/standard.png',
    primaryColor: Color(0xFF4A6572),
    accentColor: Color(0xFFFF8A65),
    isPremium: false,
  );

  static const professional = ResumeTemplate(
    id: 'professional',
    name: 'Profesional',
    description: 'Template formal dengan tampilan yang rapi dan terstruktur',
    previewImage: 'assets/images/templates/professional.png',
    primaryColor: Color(0xFF1A237E),
    accentColor: Color(0xFF42A5F5),
    isPremium: false,
  );

  static const creative = ResumeTemplate(
    id: 'creative',
    name: 'Kreatif',
    description: 'Template modern untuk industri kreatif dan desain',
    previewImage: 'assets/images/templates/creative.png',
    primaryColor: Color(0xFF6A1B9A),
    accentColor: Color(0xFFEC407A),
    isPremium: true,
  );

  static const academic = ResumeTemplate(
    id: 'academic',
    name: 'Akademis',
    description: 'Template formal untuk posisi akademis dan penelitian',
    previewImage: 'assets/images/templates/academic.png',
    primaryColor: Color(0xFF1B5E20),
    accentColor: Color(0xFF66BB6A),
    isPremium: true,
  );

  static const minimal = ResumeTemplate(
    id: 'minimal',
    name: 'Minimalis',
    description: 'Template simpel dengan fokus pada konten',
    previewImage: 'assets/images/templates/minimal.png',
    primaryColor: Color(0xFF212121),
    accentColor: Color(0xFF757575),
    isPremium: true,
  );

  static const modern = ResumeTemplate(
    id: 'modern',
    name: 'Modern',
    description: 'Template kontemporer dengan layout yang dinamis',
    previewImage: 'assets/images/templates/modern.png',
    primaryColor: Color(0xFF00796B),
    accentColor: Color(0xFFFFB74D),
    isPremium: true,
  );

  static const executive = ResumeTemplate(
    id: 'executive',
    name: 'Eksekutif',
    description: 'Template elegan untuk posisi manajemen dan eksekutif',
    previewImage: 'assets/images/templates/executive.png',
    primaryColor: Color(0xFF3E2723),
    accentColor: Color(0xFFD4AC0D),
    isPremium: true,
  );

  static const technical = ResumeTemplate(
    id: 'technical',
    name: 'Teknikal',
    description: 'Template khusus untuk posisi IT dan teknik',
    previewImage: 'assets/images/templates/technical.png',
    primaryColor: Color(0xFF0D47A1),
    accentColor: Color(0xFF64B5F6),
    isPremium: true,
  );

  static const luxury = ResumeTemplate(
    id: 'luxury',
    name: 'Luxury',
    description: 'Template mewah dengan aksen emas untuk posisi eksekutif tinggi',
    previewImage: 'assets/images/templates/luxury.png',
    primaryColor: Color(0xFF1A1A1A),
    accentColor: Color(0xFFD4AF37),
    isPremium: true,
  );

  static const techStartup = ResumeTemplate(
    id: 'tech_startup',
    name: 'Tech Startup',
    description: 'Template modern untuk startup dan tech company',
    previewImage: 'assets/images/templates/tech_startup.png',
    primaryColor: Color(0xFF6C63FF),
    accentColor: Color(0xFF00D4AA),
    isPremium: true,
  );

  static const healthcare = ResumeTemplate(
    id: 'healthcare',
    name: 'Healthcare',
    description: 'Template profesional untuk tenaga medis dan kesehatan',
    previewImage: 'assets/images/templates/healthcare.png',
    primaryColor: Color(0xFF2E7D32),
    accentColor: Color(0xFF81C784),
    isPremium: true,
  );

  static const finance = ResumeTemplate(
    id: 'finance',
    name: 'Finance',
    description: 'Template konservatif untuk industri perbankan dan keuangan',
    previewImage: 'assets/images/templates/finance.png',
    primaryColor: Color(0xFF1565C0),
    accentColor: Color(0xFF42A5F5),
    isPremium: true,
  );

  static const marketing = ResumeTemplate(
    id: 'marketing',
    name: 'Marketing',
    description: 'Template kreatif untuk marketing dan advertising professionals',
    previewImage: 'assets/images/templates/marketing.png',
    primaryColor: Color(0xFFE91E63),
    accentColor: Color(0xFFFF9800),
    isPremium: true,
  );

  static const legal = ResumeTemplate(
    id: 'legal',
    name: 'Legal',
    description: 'Template formal untuk profesi hukum dan legal',
    previewImage: 'assets/images/templates/legal.png',
    primaryColor: Color(0xFF424242),
    accentColor: Color(0xFF757575),
    isPremium: true,
  );

  static const consulting = ResumeTemplate(
    id: 'consulting',
    name: 'Consulting',
    description: 'Template premium untuk konsultan dan business advisor',
    previewImage: 'assets/images/templates/consulting.png',
    primaryColor: Color(0xFF5D4037),
    accentColor: Color(0xFFFF7043),
    isPremium: true,
  );

  static const designer = ResumeTemplate(
    id: 'designer',
    name: 'Designer',
    description: 'Template artistik untuk graphic designer dan creative professional',
    previewImage: 'assets/images/templates/designer.png',
    primaryColor: Color(0xFF7B1FA2),
    accentColor: Color(0xFFE1BEE7),
    isPremium: true,
  );

  static List<ResumeTemplate> get all => [
    standard,
    professional,
    creative,
    academic,
    minimal,
    modern,
    executive,
    technical,
    luxury,
    techStartup,
    healthcare,
    finance,
    marketing,
    legal,
    consulting,
    designer,
  ];

  static ResumeTemplate getById(String id) {
    return all.firstWhere(
      (template) => template.id == id,
      orElse: () => standard,
    );
  }
}
