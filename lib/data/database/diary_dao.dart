import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../models/diary.dart';
import '../../models/enums.dart';
import 'database_helper.dart';

/// 日記用のData Access Object
class DiaryDao {
  final DatabaseHelper _dbHelper;

  DiaryDao(this._dbHelper);

  /// 日記を挿入
  Future<void> insert(Diary diary) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // メインの日記を挿入
      await txn.insert(
        AppConstants.diaryTable,
        _diaryToMap(diary),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 関連ToDoを挿入
      for (final todoId in diary.relatedTodoIds) {
        await txn.insert(AppConstants.diaryTodoTable, {
          'diary_id': diary.id,
          'todo_id': todoId,
        });
      }
    });
  }

  /// 日記を更新
  Future<void> update(Diary diary) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // メインの日記を更新
      await txn.update(
        AppConstants.diaryTable,
        _diaryToMap(diary),
        where: 'id = ?',
        whereArgs: [diary.id],
      );

      // 関連ToDoを削除して再挿入
      await txn.delete(
        AppConstants.diaryTodoTable,
        where: 'diary_id = ?',
        whereArgs: [diary.id],
      );
      for (final todoId in diary.relatedTodoIds) {
        await txn.insert(AppConstants.diaryTodoTable, {
          'diary_id': diary.id,
          'todo_id': todoId,
        });
      }
    });
  }

  /// 日記を削除
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.diaryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// IDで日記を取得
  Future<Diary?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.diaryTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final relatedTodoIds = await _getRelatedTodoIds(db, id);
    return _mapToDiary(maps.first, relatedTodoIds);
  }

  /// 日付で日記を取得
  Future<Diary?> getByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      AppConstants.diaryTable,
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isEmpty) return null;

    final relatedTodoIds = await _getRelatedTodoIds(db, maps.first['id'] as String);
    return _mapToDiary(maps.first, relatedTodoIds);
  }

  /// すべての日記を取得
  Future<List<Diary>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.diaryTable,
      orderBy: 'date DESC',
    );

    return _mapListToDiaries(db, maps);
  }

  /// 指定期間の日記を取得
  Future<List<Diary>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      AppConstants.diaryTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );

    return _mapListToDiaries(db, maps);
  }

  /// 指定月の日記を取得
  Future<List<Diary>> getByMonth(int year, int month) async {
    final db = await _dbHelper.database;
    final monthStr = '$year-${month.toString().padLeft(2, '0')}';

    final maps = await db.query(
      AppConstants.diaryTable,
      where: 'date LIKE ?',
      whereArgs: ['$monthStr%'],
      orderBy: 'date DESC',
    );

    return _mapListToDiaries(db, maps);
  }

  /// 日記がある日付のリストを取得
  Future<List<DateTime>> getDatesWithDiary(int year, int month) async {
    final db = await _dbHelper.database;
    final monthStr = '$year-${month.toString().padLeft(2, '0')}';

    final maps = await db.query(
      AppConstants.diaryTable,
      columns: ['date'],
      where: 'date LIKE ?',
      whereArgs: ['$monthStr%'],
    );

    return maps.map((m) => DateTime.parse(m['date'] as String)).toList();
  }

  /// 気分の統計を取得（指定期間）
  Future<Map<Mood, int>> getMoodStatistics(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final maps = await db.rawQuery('''
      SELECT mood, COUNT(*) as count
      FROM ${AppConstants.diaryTable}
      WHERE date >= ? AND date <= ?
      GROUP BY mood
    ''', [startStr, endStr]);

    final stats = <Mood, int>{};
    for (final map in maps) {
      final mood = Mood.fromValue(map['mood'] as int);
      stats[mood] = map['count'] as int;
    }
    return stats;
  }

  /// 日記をMapに変換
  Map<String, dynamic> _diaryToMap(Diary diary) {
    final dateStr = '${diary.date.year}-${diary.date.month.toString().padLeft(2, '0')}-${diary.date.day.toString().padLeft(2, '0')}';
    return {
      'id': diary.id,
      'date': dateStr,
      'content': diary.content,
      'mood': diary.mood.value,
      'created_at': diary.createdAt.toIso8601String(),
      'updated_at': diary.updatedAt?.toIso8601String(),
    };
  }

  /// MapからDiaryに変換
  Diary _mapToDiary(Map<String, dynamic> map, List<String> relatedTodoIds) {
    return Diary(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      content: map['content'] as String,
      mood: Mood.fromValue(map['mood'] as int? ?? 3),
      relatedTodoIds: relatedTodoIds,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// 関連ToDoのIDリストを取得
  Future<List<String>> _getRelatedTodoIds(Database db, String diaryId) async {
    final maps = await db.query(
      AppConstants.diaryTodoTable,
      where: 'diary_id = ?',
      whereArgs: [diaryId],
    );
    return maps.map((m) => m['todo_id'] as String).toList();
  }

  /// Map一覧をDiary一覧に変換
  Future<List<Diary>> _mapListToDiaries(
    Database db,
    List<Map<String, dynamic>> maps,
  ) async {
    final diaries = <Diary>[];
    for (final map in maps) {
      final relatedTodoIds = await _getRelatedTodoIds(db, map['id'] as String);
      diaries.add(_mapToDiary(map, relatedTodoIds));
    }
    return diaries;
  }
}

