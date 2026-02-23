import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

/// SQLiteデータベースのヘルパークラス
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ToDoテーブル
    await db.execute('''
      CREATE TABLE ${AppConstants.todoTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        is_completed INTEGER DEFAULT 0,
        priority INTEGER DEFAULT 1,
        category TEXT,
        due_date TEXT,
        reminder_date_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        completed_at TEXT
      )
    ''');

    // ToDoタグテーブル（多対多の関係）
    await db.execute('''
      CREATE TABLE ${AppConstants.todoTagTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todo_id TEXT NOT NULL,
        tag TEXT NOT NULL,
        FOREIGN KEY (todo_id) REFERENCES ${AppConstants.todoTable}(id) ON DELETE CASCADE
      )
    ''');

    // 日記テーブル
    await db.execute('''
      CREATE TABLE ${AppConstants.diaryTable} (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        content TEXT NOT NULL,
        mood INTEGER DEFAULT 3,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // 日記とToDoの関連テーブル
    await db.execute('''
      CREATE TABLE ${AppConstants.diaryTodoTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diary_id TEXT NOT NULL,
        todo_id TEXT NOT NULL,
        FOREIGN KEY (diary_id) REFERENCES ${AppConstants.diaryTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (todo_id) REFERENCES ${AppConstants.todoTable}(id) ON DELETE CASCADE
      )
    ''');

    // インデックス作成
    await db.execute('''
      CREATE INDEX idx_todo_due_date ON ${AppConstants.todoTable}(due_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_todo_is_completed ON ${AppConstants.todoTable}(is_completed)
    ''');
    await db.execute('''
      CREATE INDEX idx_diary_date ON ${AppConstants.diaryTable}(date)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // マイグレーション処理（将来のバージョンアップ用）
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }

  /// データベースを閉じる
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

