import '../../data/database/todo_dao.dart';
import '../../models/todo.dart';
import '../../models/enums.dart';
import '../../services/notification_service.dart';
import '../../core/utils/uuid_generator.dart';

/// ToDoに関するユースケース
class TodoUseCases {
  final TodoDao _todoDao;
  final NotificationService _notificationService;

  TodoUseCases(this._todoDao, this._notificationService);

  /// すべてのToDoを取得
  Future<List<Todo>> getAllTodos() async {
    return await _todoDao.getAll();
  }

  /// フィルタリングされたToDoを取得
  Future<List<Todo>> getFilteredTodos({
    TodoFilter filter = TodoFilter.all,
    String? category,
    String? searchQuery,
    TodoSortBy sortBy = TodoSortBy.createdAt,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    return await _todoDao.getFiltered(
      filter: filter,
      category: category,
      searchQuery: searchQuery,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// 指定日のToDoを取得
  Future<List<Todo>> getTodosByDate(DateTime date) async {
    return await _todoDao.getByDate(date);
  }

  /// ToDoを追加
  Future<Todo> addTodo({
    required String title,
    String description = '',
    Priority priority = Priority.medium,
    String? category,
    List<String> tags = const [],
    DateTime? dueDate,
    DateTime? reminderDateTime,
  }) async {
    final todo = Todo(
      id: UuidGenerator.generate(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      tags: tags,
      dueDate: dueDate,
      reminderDateTime: reminderDateTime,
      createdAt: DateTime.now(),
    );

    await _todoDao.insert(todo);

    // リマインダーがある場合は通知をスケジュール
    if (todo.reminderDateTime != null) {
      await _notificationService.scheduleReminder(todo);
    }

    return todo;
  }

  /// ToDoを更新
  Future<Todo> updateTodo(Todo todo) async {
    final updatedTodo = todo.copyWith(updatedAt: DateTime.now());
    await _todoDao.update(updatedTodo);

    // 通知を更新
    await _notificationService.cancelReminder(todo.id);
    if (updatedTodo.reminderDateTime != null && !updatedTodo.isCompleted) {
      await _notificationService.scheduleReminder(updatedTodo);
    }

    return updatedTodo;
  }

  /// ToDoを削除
  Future<void> deleteTodo(String id) async {
    await _notificationService.cancelReminder(id);
    await _todoDao.delete(id);
  }

  /// ToDoの完了状態を切り替え
  Future<Todo?> toggleCompletion(String id) async {
    final todo = await _todoDao.getById(id);
    if (todo == null) return null;

    final isCompleted = !todo.isCompleted;
    await _todoDao.updateCompletionStatus(id, isCompleted);

    // 完了時は通知をキャンセル
    if (isCompleted) {
      await _notificationService.cancelReminder(id);
    } else if (todo.reminderDateTime != null) {
      // 未完了に戻した場合はリマインダーを再設定
      await _notificationService.scheduleReminder(todo);
    }

    return await _todoDao.getById(id);
  }

  /// ToDoをIDで取得
  Future<Todo?> getTodoById(String id) async {
    return await _todoDao.getById(id);
  }
}

