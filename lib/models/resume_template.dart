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

  static List<ResumeTemplate> get all => [
    standard,
    professional,
    creative,
    academic,
    minimal,
    modern,
    executive,
    technical,
  ];

  static ResumeTemplate getById(String id) {
    return all.firstWhere(
      (template) => template.id == id,
      orElse: () => standard,
    );
  }
}
