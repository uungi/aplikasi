import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'user_input.dart';

class ResumeDraft {
  final String id;
  final String name;
  final UserInput input;
  final String? resumeContent;
  final String? coverLetterContent;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  ResumeDraft({
    String? id,
    required this.name,
    required this.input,
    this.resumeContent,
    this.coverLetterContent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  // Create a copy with updated fields
  ResumeDraft copyWith({
    String? name,
    UserInput? input,
    String? resumeContent,
    String? coverLetterContent,
    DateTime? updatedAt,
  }) {
    return ResumeDraft(
      id: id,
      name: name ?? this.name,
      input: input ?? this.input,
      resumeContent: resumeContent ?? this.resumeContent,
      coverLetterContent: coverLetterContent ?? this.coverLetterContent,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'input': jsonEncode(input.toMap()),
      'resumeContent': resumeContent,
      'coverLetterContent': coverLetterContent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Create from Map from database
  factory ResumeDraft.fromMap(Map<String, dynamic> map) {
    return ResumeDraft(
      id: map['id'],
      name: map['name'],
      input: UserInput.fromMap(jsonDecode(map['input'])),
      resumeContent: map['resumeContent'],
      coverLetterContent: map['coverLetterContent'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
