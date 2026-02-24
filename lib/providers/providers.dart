import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../data/database/todo_dao.dart';
import '../data/database/diary_dao.dart';
import '../domain/usecases/todo_usecases.dart';
import '../domain/usecases/diary_usecases.dart';
import '../services/notification_service.dart';
import '../models/todo.dart';
import '../models/diary.dart';
import '../models/enums.dart';

// ==================== Database & DAO Providers ====================

/// DatabaseHelper Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// TodoDao Provider
final todoDaoProvider = Provider<TodoDao>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TodoDao(dbHelper);
});

/// DiaryDao Provider
final diaryDaoProvider = Provider<DiaryDao>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return DiaryDao(dbHelper);
});

// ==================== Service Providers ====================

/// NotificationService Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

// ==================== UseCase Providers ====================

/// TodoUseCases Provider
final todoUseCasesProvider = Provider<TodoUseCases>((ref) {
  final todoDao = ref.watch(todoDaoProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return TodoUseCases(todoDao, notificationService);
});

/// DiaryUseCases Provider
final diaryUseCasesProvider = Provider<DiaryUseCases>((ref) {
  final diaryDao = ref.watch(diaryDaoProvider);
  final todoDao = ref.watch(todoDaoProvider);
  return DiaryUseCases(diaryDao, todoDao);
});

// ==================== State Providers ====================

/// ToDoフィルター状態
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

/// ToDoソート状態
final todoSortByProvider = StateProvider<TodoSortBy>((ref) => TodoSortBy.createdAt);

/// ToDoソート順
final todoSortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.descending);

/// ToDo検索クエリ
final todoSearchQueryProvider = StateProvider<String>((ref) => '');

/// ToDoカテゴリフィルター
final todoCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// 選択中の日付（カレンダー用）
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ==================== ToDo Notifier ====================

/// ToDoリストの状態管理
class TodoNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    return _fetchTodos();
  }

  Future<List<Todo>> _fetchTodos() async {
    final useCases = ref.read(todoUseCasesProvider);
    final filter = ref.read(todoFilterProvider);
    final sortBy = ref.read(todoSortByProvider);
    final sortOrder = ref.read(todoSortOrderProvider);
    final searchQuery = ref.read(todoSearchQueryProvider);
    final category = ref.read(todoCategoryFilterProvider);

    return await useCases.getFilteredTodos(
      filter: filter,
      sortBy: sortBy,
      sortOrder: sortOrder,
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
      category: category,
    );
  }

  /// ToDoを追加
  Future<void> addTodo({
    required String title,
    String description = '',
    Priority priority = Priority.medium,
    String? category,
    List<String> tags = const [],
    DateTime? dueDate,
    DateTime? reminderDateTime,
  }) async {
    final useCases = ref.read(todoUseCasesProvider);
    await useCases.addTodo(
      title: title,
      description: description,
      priority: priority,
      category: category,
      tags: tags,
      dueDate: dueDate,
      reminderDateTime: reminderDateTime,
    );
    ref.invalidateSelf();
  }

  /// ToDoを更新
  Future<void> updateTodo(Todo todo) async {
    final useCases = ref.read(todoUseCasesProvider);
    await useCases.updateTodo(todo);
    ref.invalidateSelf();
  }

  /// ToDoを削除
  Future<void> deleteTodo(String id) async {
    final useCases = ref.read(todoUseCasesProvider);
    await useCases.deleteTodo(id);
    ref.invalidateSelf();
  }

  /// 完了状態を切り替え
  Future<void> toggleCompletion(String id) async {
    final useCases = ref.read(todoUseCasesProvider);
    await useCases.toggleCompletion(id);
    ref.invalidateSelf();
  }

  /// リストを再読み込み
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// ToDoリストProvider
final todoListProvider = AsyncNotifierProvider<TodoNotifier, List<Todo>>(() {
  return TodoNotifier();
});

// ==================== Diary Notifier ====================

/// 日記リストの状態管理
class DiaryNotifier extends AsyncNotifier<List<Diary>> {
  @override
  Future<List<Diary>> build() async {
    return _fetchDiaries();
  }

  Future<List<Diary>> _fetchDiaries() async {
    final useCases = ref.read(diaryUseCasesProvider);
    return await useCases.getAllDiaries();
  }

  /// 日記を保存（追加または更新）
  Future<Diary> saveDiary({
    required DateTime date,
    required String content,
    Mood mood = Mood.neutral,
    List<String> relatedTodoIds = const [],
    String? existingId,
  }) async {
    final useCases = ref.read(diaryUseCasesProvider);
    final diary = await useCases.saveDiary(
      date: date,
      content: content,
      mood: mood,
      relatedTodoIds: relatedTodoIds,
      existingId: existingId,
    );
    ref.invalidateSelf();
    return diary;
  }

  /// 日記を削除
  Future<void> deleteDiary(String id) async {
    final useCases = ref.read(diaryUseCasesProvider);
    await useCases.deleteDiary(id);
    ref.invalidateSelf();
  }

  /// リストを再読み込み
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// 日記リストProvider
final diaryListProvider = AsyncNotifierProvider<DiaryNotifier, List<Diary>>(() {
  return DiaryNotifier();
});

// ==================== 派生Provider ====================

/// 選択日の日記を取得
final selectedDateDiaryProvider = FutureProvider<Diary?>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final useCases = ref.read(diaryUseCasesProvider);
  return await useCases.getDiaryByDate(selectedDate);
});

/// 選択日のToDoを取得
final selectedDateTodosProvider = FutureProvider<List<Todo>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final useCases = ref.read(todoUseCasesProvider);
  return await useCases.getTodosByDate(selectedDate);
});

/// 今日のToDoを取得
final todayTodosProvider = FutureProvider<List<Todo>>((ref) async {
  final useCases = ref.read(todoUseCasesProvider);
  return await useCases.getTodosByDate(DateTime.now());
});

/// 指定月の日記がある日付リスト
final diaryDatesProvider = FutureProvider.family<List<DateTime>, DateTime>((ref, month) async {
  final useCases = ref.read(diaryUseCasesProvider);
  return await useCases.getDatesWithDiary(month.year, month.month);
});

