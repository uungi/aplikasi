import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/resume_draft.dart';
import '../models/custom_template.dart';
import '../models/offline_template.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'resume_generator.db');
    
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }
  
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE resume_drafts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        input TEXT NOT NULL,
        resumeContent TEXT,
        coverLetterContent TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE custom_templates(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        primaryColor INTEGER NOT NULL,
        accentColor INTEGER NOT NULL,
        layout TEXT NOT NULL,
        sections TEXT NOT NULL,
        fontFamily TEXT NOT NULL,
        fontSize REAL NOT NULL,
        isPremium INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE offline_templates(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE custom_templates(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          primaryColor INTEGER NOT NULL,
          accentColor INTEGER NOT NULL,
          layout TEXT NOT NULL,
          sections TEXT NOT NULL,
          fontFamily TEXT NOT NULL,
          fontSize REAL NOT NULL,
          isPremium INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE offline_templates(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          content TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    }
  }
  
  // CRUD Operations for Resume Drafts
  
  // Create
  Future<String> insertDraft(ResumeDraft draft) async {
    final db = await database;
    await db.insert(
      'resume_drafts',
      draft.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return draft.id;
  }
  
  // Read
  Future<ResumeDraft?> getDraft(String id) async {
    final db = await database;
    final maps = await db.query(
      'resume_drafts',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return ResumeDraft.fromMap(maps.first);
    }
    return null;
  }
  
  // Read All
  Future<List<ResumeDraft>> getAllDrafts() async {
    final db = await database;
    final maps = await db.query(
      'resume_drafts',
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ResumeDraft.fromMap(maps[i]);
    });
  }
  
  // Update
  Future<int> updateDraft(ResumeDraft draft) async {
    final db = await database;
    return await db.update(
      'resume_drafts',
      draft.toMap(),
      where: 'id = ?',
      whereArgs: [draft.id],
    );
  }
  
  // Delete
  Future<int> deleteDraft(String id) async {
    final db = await database;
    return await db.delete(
      'resume_drafts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete All
  Future<int> deleteAllDrafts() async {
    final db = await database;
    return await db.delete('resume_drafts');
  }
  
  // CRUD Operations for Custom Templates
  
  // Create
  Future<String> insertTemplate(CustomTemplate template) async {
    final db = await database;
    await db.insert(
      'custom_templates',
      template.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return template.id;
  }
  
  // Read
  Future<CustomTemplate?> getTemplate(String id) async {
    final db = await database;
    final maps = await db.query(
      'custom_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return CustomTemplate.fromMap(maps.first);
    }
    return null;
  }
  
  // Read All
  Future<List<CustomTemplate>> getAllTemplates() async {
    final db = await database;
    final maps = await db.query(
      'custom_templates',
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CustomTemplate.fromMap(maps[i]);
    });
  }
  
  // Update
  Future<int> updateTemplate(CustomTemplate template) async {
    final db = await database;
    return await db.update(
      'custom_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }
  
  // Delete
  Future<int> deleteTemplate(String id) async {
    final db = await database;
    return await db.delete(
      'custom_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete All
  Future<int> deleteAllTemplates() async {
    final db = await database;
    return await db.delete('custom_templates');
  }
  
  // CRUD Operations for Offline Templates
  
  // Create
  Future<String> insertOfflineTemplate(OfflineTemplate template) async {
    final db = await database;
    await db.insert(
      'offline_templates',
      template.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return template.id;
  }
  
  // Read
  Future<OfflineTemplate?> getOfflineTemplate(String id) async {
    final db = await database;
    final maps = await db.query(
      'offline_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return OfflineTemplate.fromMap(maps.first);
    }
    return null;
  }
  
  // Read All
  Future<List<OfflineTemplate>> getAllOfflineTemplates() async {
    final db = await database;
    final maps = await db.query(
      'offline_templates',
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return OfflineTemplate.fromMap(maps[i]);
    });
  }
  
  // Read All by Type
  Future<List<OfflineTemplate>> getOfflineTemplatesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'offline_templates',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return OfflineTemplate.fromMap(maps[i]);
    });
  }
  
  // Update
  Future<int> updateOfflineTemplate(OfflineTemplate template) async {
    final db = await database;
    return await db.update(
      'offline_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }
  
  // Delete
  Future<int> deleteOfflineTemplate(String id) async {
    final db = await database;
    return await db.delete(
      'offline_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete All
  Future<int> deleteAllOfflineTemplates() async {
    final db = await database;
    return await db.delete('offline_templates');
  }
  
  // Initialize default offline templates if none exist
  Future<void> initializeDefaultOfflineTemplates() async {
    final templates = await getAllOfflineTemplates();
    if (templates.isEmpty) {
      final defaultTemplates = OfflineTemplate.getDefaultTemplates();
      for (var template in defaultTemplates) {
        await insertOfflineTemplate(template);
      }
    }
  }
}
