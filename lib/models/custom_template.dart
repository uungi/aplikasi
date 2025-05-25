import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CustomTemplate {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final Map<String, dynamic> layout;
  final List<String> sections;
  final String fontFamily;
  final double fontSize;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  CustomTemplate({
    String? id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.layout,
    required this.sections,
    this.fontFamily = 'Roboto',
    this.fontSize = 14.0,
    this.isPremium = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  // Create a copy with updated fields
  CustomTemplate copyWith({
    String? name,
    String? description,
    Color? primaryColor,
    Color? accentColor,
    Map<String, dynamic>? layout,
    List<String>? sections,
    String? fontFamily,
    double? fontSize,
    bool? isPremium,
    DateTime? updatedAt,
  }) {
    return CustomTemplate(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      layout: layout ?? Map.from(this.layout),
      sections: sections ?? List.from(this.sections),
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'layout': jsonEncode(layout),
      'sections': jsonEncode(sections),
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'isPremium': isPremium ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Create from Map from database
  factory CustomTemplate.fromMap(Map<String, dynamic> map) {
    return CustomTemplate(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      primaryColor: Color(map['primaryColor']),
      accentColor: Color(map['accentColor']),
      layout: jsonDecode(map['layout']),
      sections: List<String>.from(jsonDecode(map['sections'])),
      fontFamily: map['fontFamily'],
      fontSize: map['fontSize'],
      isPremium: map['isPremium'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
  
  // Default template layouts
  static Map<String, dynamic> getDefaultLayout(String type) {
    switch (type) {
      case 'modern':
        return {
          'header': {
            'type': 'box',
            'color': 'primary',
            'padding': 20.0,
            'borderRadius': 0.0,
            'alignment': 'left',
          },
          'body': {
            'type': 'column',
            'padding': 20.0,
            'spacing': 16.0,
          },
          'section': {
            'type': 'card',
            'elevation': 2.0,
            'padding': 16.0,
            'borderRadius': 8.0,
            'margin': 8.0,
          },
          'title': {
            'size': 18.0,
            'weight': 'bold',
            'color': 'primary',
            'spacing': 8.0,
          },
          'subtitle': {
            'size': 16.0,
            'weight': 'medium',
            'color': 'accent',
            'spacing': 4.0,
          },
          'text': {
            'size': 14.0,
            'weight': 'normal',
            'color': 'text',
            'spacing': 2.0,
          },
        };
      case 'minimal':
        return {
          'header': {
            'type': 'box',
            'color': 'transparent',
            'padding': 20.0,
            'borderRadius': 0.0,
            'alignment': 'center',
          },
          'body': {
            'type': 'column',
            'padding': 20.0,
            'spacing': 24.0,
          },
          'section': {
            'type': 'box',
            'elevation': 0.0,
            'padding': 16.0,
            'borderRadius': 0.0,
            'margin': 0.0,
            'border': {
              'bottom': true,
              'color': 'divider',
              'width': 1.0,
            },
          },
          'title': {
            'size': 16.0,
            'weight': 'bold',
            'color': 'text',
            'spacing': 8.0,
            'transform': 'uppercase',
          },
          'subtitle': {
            'size': 14.0,
            'weight': 'medium',
            'color': 'text',
            'spacing': 4.0,
          },
          'text': {
            'size': 14.0,
            'weight': 'normal',
            'color': 'text',
            'spacing': 2.0,
          },
        };
      case 'professional':
        return {
          'header': {
            'type': 'box',
            'color': 'white',
            'padding': 20.0,
            'borderRadius': 0.0,
            'alignment': 'left',
            'border': {
              'bottom': true,
              'color': 'primary',
              'width': 2.0,
            },
          },
          'body': {
            'type': 'column',
            'padding': 20.0,
            'spacing': 16.0,
          },
          'section': {
            'type': 'box',
            'elevation': 0.0,
            'padding': 16.0,
            'borderRadius': 0.0,
            'margin': 8.0,
          },
          'title': {
            'size': 18.0,
            'weight': 'bold',
            'color': 'primary',
            'spacing': 8.0,
          },
          'subtitle': {
            'size': 16.0,
            'weight': 'medium',
            'color': 'text',
            'spacing': 4.0,
          },
          'text': {
            'size': 14.0,
            'weight': 'normal',
            'color': 'text',
            'spacing': 2.0,
          },
        };
      case 'creative':
        return {
          'header': {
            'type': 'box',
            'color': 'accent',
            'padding': 24.0,
            'borderRadius': 16.0,
            'alignment': 'center',
            'margin': 16.0,
          },
          'body': {
            'type': 'column',
            'padding': 16.0,
            'spacing': 24.0,
          },
          'section': {
            'type': 'card',
            'elevation': 3.0,
            'padding': 16.0,
            'borderRadius': 16.0,
            'margin': 8.0,
            'border': {
              'all': true,
              'color': 'accent',
              'width': 1.0,
            },
          },
          'title': {
            'size': 20.0,
            'weight': 'bold',
            'color': 'primary',
            'spacing': 8.0,
          },
          'subtitle': {
            'size': 16.0,
            'weight': 'medium',
            'color': 'accent',
            'spacing': 4.0,
            'style': 'italic',
          },
          'text': {
            'size': 14.0,
            'weight': 'normal',
            'color': 'text',
            'spacing': 2.0,
          },
        };
      default: // standard
        return {
          'header': {
            'type': 'box',
            'color': 'white',
            'padding': 16.0,
            'borderRadius': 0.0,
            'alignment': 'left',
          },
          'body': {
            'type': 'column',
            'padding': 16.0,
            'spacing': 16.0,
          },
          'section': {
            'type': 'box',
            'elevation': 0.0,
            'padding': 16.0,
            'borderRadius': 0.0,
            'margin': 0.0,
          },
          'title': {
            'size': 18.0,
            'weight': 'bold',
            'color': 'text',
            'spacing': 8.0,
          },
          'subtitle': {
            'size': 16.0,
            'weight': 'medium',
            'color': 'text',
            'spacing': 4.0,
          },
          'text': {
            'size': 14.0,
            'weight': 'normal',
            'color': 'text',
            'spacing': 2.0,
          },
        };
    }
  }
  
  // Default sections
  static List<String> getDefaultSections() {
    return [
      'header',
      'summary',
      'experience',
      'education',
      'skills',
      'contact',
    ];
  }
  
  // Create a template from a predefined type
  factory CustomTemplate.fromType(String type, {
    required String name,
    required String description,
    required Color primaryColor,
    required Color accentColor,
  }) {
    return CustomTemplate(
      name: name,
      description: description,
      primaryColor: primaryColor,
      accentColor: accentColor,
      layout: getDefaultLayout(type),
      sections: getDefaultSections(),
    );
  }
}
