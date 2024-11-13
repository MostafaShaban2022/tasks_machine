import 'package:flutter/foundation.dart';
import 'package:flutter_application_7/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = 'tasks';
  final String _tasksIdColumnName = 'task_id';
  final String _tasksContentColumnName = 'task_content';
  final String _tasksStatusColumnName = 'task_status';

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_tasksTableName(
          $_tasksIdColumnName INTEGER PRIMARY KEY,
          $_tasksContentColumnName TEXT NOT NULL,
          $_tasksStatusColumnName INTEGER NOT NULL
          )
        ''');
      },
    );
    return database;
  }

  void addTask(String content) async {
    final db = await database;
    await db.insert(_tasksTableName, {
      _tasksContentColumnName: content,
      _tasksStatusColumnName: 0,
    });
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    List<Task> tasks = data
        .map(
          (e) => Task(
            id: e[_tasksIdColumnName] as int,
            status: e[_tasksStatusColumnName] as int,
            content: e[_tasksContentColumnName] as String,
          ),
        )
        .toList();
    if (kDebugMode) {
      print(data);
    }
    return tasks;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {
        _tasksStatusColumnName: status, // Correct column for status
      },
      where: '$_tasksIdColumnName = ?', // Use the correct column name here
      whereArgs: [id], // Correctly pass the task id
    );
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _tasksTableName,
      where: '$_tasksIdColumnName = ?', // Use the correct column name here
      whereArgs: [id], // Correctly pass the task id
    );
  }
}
