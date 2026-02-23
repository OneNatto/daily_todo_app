import '../../data/database/diary_dao.dart';
import '../../data/database/todo_dao.dart';
import '../../models/diary.dart';
import '../../models/todo.dart';
import '../../models/enums.dart';
import '../../core/utils/uuid_generator.dart';

/// 日記に関するユースケース
class DiaryUseCases {
  final DiaryDao _diaryDao;
  final TodoDao _todoDao;

  DiaryUseCases(this._diaryDao, this._todoDao);

  /// すべての日記を取得
  Future<List<Diary>> getAllDiaries() async {
    return await _diaryDao.getAll();
  }

  /// 指定日の日記を取得
  Future<Diary?> getDiaryByDate(DateTime date) async {
    return await _diaryDao.getByDate(date);
  }

  /// 指定期間の日記を取得
  Future<List<Diary>> getDiariesByDateRange(DateTime start, DateTime end) async {
    return await _diaryDao.getByDateRange(start, end);
  }

  /// 指定月の日記を取得
  Future<List<Diary>> getDiariesByMonth(int year, int month) async {
    return await _diaryDao.getByMonth(year, month);
  }

  /// 日記を追加または更新
  Future<Diary> saveDiary({
    required DateTime date,
    required String content,
    Mood mood = Mood.neutral,
    List<String> relatedTodoIds = const [],
    String? existingId,
  }) async {
    final existing = existingId != null
        ? await _diaryDao.getById(existingId)
        : await _diaryDao.getByDate(date);

    if (existing != null) {
      // 更新
      final updatedDiary = existing.copyWith(
        content: content,
        mood: mood,
        relatedTodoIds: relatedTodoIds,
        updatedAt: DateTime.now(),
      );
      await _diaryDao.update(updatedDiary);
      return updatedDiary;
    } else {
      // 新規作成
      final diary = Diary(
        id: UuidGenerator.generate(),
        date: date,
        content: content,
        mood: mood,
        relatedTodoIds: relatedTodoIds,
        createdAt: DateTime.now(),
      );
      await _diaryDao.insert(diary);
      return diary;
    }
  }

  /// 日記を削除
  Future<void> deleteDiary(String id) async {
    await _diaryDao.delete(id);
  }

  /// 指定日のToDoを取得（日記画面で関連付け用）
  Future<List<Todo>> getTodosForDate(DateTime date) async {
    return await _todoDao.getByDate(date);
  }

  /// 日記がある日付のリストを取得（カレンダー表示用）
  Future<List<DateTime>> getDatesWithDiary(int year, int month) async {
    return await _diaryDao.getDatesWithDiary(year, month);
  }

  /// 気分の統計を取得
  Future<Map<Mood, int>> getMoodStatistics(DateTime start, DateTime end) async {
    return await _diaryDao.getMoodStatistics(start, end);
  }

  /// 日記に関連付けられたToDoを取得
  Future<List<Todo>> getRelatedTodos(Diary diary) async {
    final todos = <Todo>[];
    for (final todoId in diary.relatedTodoIds) {
      final todo = await _todoDao.getById(todoId);
      if (todo != null) {
        todos.add(todo);
      }
    }
    return todos;
  }
}

