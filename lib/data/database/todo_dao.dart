import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../models/todo.dart';
import '../../models/enums.dart';
import 'database_helper.dart';

/// ToDo用のData Access Object
class TodoDao {
  final DatabaseHelper _dbHelper;

  TodoDao(this._dbHelper);

  /// ToDoを挿入
  Future<void> insert(Todo todo) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // メインのToDoを挿入
      await txn.insert(
        AppConstants.todoTable,
        _todoToMap(todo),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // タグを挿入
      for (final tag in todo.tags) {
        await txn.insert(AppConstants.todoTagTable, {
          'todo_id': todo.id,
          'tag': tag,
        });
      }
    });
  }

  /// ToDoを更新
  Future<void> update(Todo todo) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // メインのToDoを更新
      await txn.update(
        AppConstants.todoTable,
        _todoToMap(todo),
        where: 'id = ?',
        whereArgs: [todo.id],
      );

      // タグを削除して再挿入
      await txn.delete(
        AppConstants.todoTagTable,
        where: 'todo_id = ?',
        whereArgs: [todo.id],
      );
      for (final tag in todo.tags) {
        await txn.insert(AppConstants.todoTagTable, {
          'todo_id': todo.id,
          'tag': tag,
        });
      }
    });
  }

  /// ToDoを削除
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.todoTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// IDでToDoを取得
  Future<Todo?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.todoTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final tags = await _getTagsForTodo(db, id);
    return _mapToTodo(maps.first, tags);
  }

  /// すべてのToDoを取得
  Future<List<Todo>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.todoTable,
      orderBy: 'created_at DESC',
    );

    return _mapListToTodos(db, maps);
  }

  /// フィルタリングされたToDoを取得
  Future<List<Todo>> getFiltered({
    TodoFilter filter = TodoFilter.all,
    String? category,
    String? searchQuery,
    TodoSortBy sortBy = TodoSortBy.createdAt,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    final db = await _dbHelper.database;
    final whereClause = <String>[];
    final whereArgs = <dynamic>[];

    // フィルター条件
    switch (filter) {
      case TodoFilter.all:
        break;
      case TodoFilter.active:
        whereClause.add('is_completed = 0');
        break;
      case TodoFilter.completed:
        whereClause.add('is_completed = 1');
        break;
      case TodoFilter.today:
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        whereClause.add('date(due_date) = ?');
        whereArgs.add(todayStr);
        break;
      case TodoFilter.overdue:
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        whereClause.add('date(due_date) < ? AND is_completed = 0');
        whereArgs.add(todayStr);
        break;
    }

    // カテゴリフィルター
    if (category != null && category.isNotEmpty) {
      whereClause.add('category = ?');
      whereArgs.add(category);
    }

    // 検索クエリ
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause.add('(title LIKE ? OR description LIKE ?)');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    // ソート順
    final orderByColumn = switch (sortBy) {
      TodoSortBy.createdAt => 'created_at',
      TodoSortBy.dueDate => 'due_date',
      TodoSortBy.priority => 'priority',
      TodoSortBy.title => 'title',
    };
    final orderDirection = sortOrder == SortOrder.ascending ? 'ASC' : 'DESC';

    final maps = await db.query(
      AppConstants.todoTable,
      where: whereClause.isEmpty ? null : whereClause.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: '$orderByColumn $orderDirection',
    );

    return _mapListToTodos(db, maps);
  }

  /// 指定日のToDoを取得
  Future<List<Todo>> getByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      AppConstants.todoTable,
      where: 'date(due_date) = ?',
      whereArgs: [dateStr],
      orderBy: 'priority DESC, created_at ASC',
    );

    return _mapListToTodos(db, maps);
  }

  /// 完了状態を更新
  Future<void> updateCompletionStatus(String id, bool isCompleted) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.todoTable,
      {
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ToDoをMapに変換
  Map<String, dynamic> _todoToMap(Todo todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'is_completed': todo.isCompleted ? 1 : 0,
      'priority': todo.priority.value,
      'category': todo.category,
      'due_date': todo.dueDate?.toIso8601String(),
      'reminder_date_time': todo.reminderDateTime?.toIso8601String(),
      'created_at': todo.createdAt.toIso8601String(),
      'updated_at': todo.updatedAt?.toIso8601String(),
      'completed_at': todo.completedAt?.toIso8601String(),
    };
  }

  /// MapからToDoに変換
  Todo _mapToTodo(Map<String, dynamic> map, List<String> tags) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      isCompleted: (map['is_completed'] as int) == 1,
      priority: Priority.fromValue(map['priority'] as int? ?? 1),
      category: map['category'] as String?,
      tags: tags,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      reminderDateTime: map['reminder_date_time'] != null
          ? DateTime.parse(map['reminder_date_time'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  /// 指定ToDoのタグを取得
  Future<List<String>> _getTagsForTodo(Database db, String todoId) async {
    final maps = await db.query(
      AppConstants.todoTagTable,
      where: 'todo_id = ?',
      whereArgs: [todoId],
    );
    return maps.map((m) => m['tag'] as String).toList();
  }

  /// Map一覧をToDo一覧に変換
  Future<List<Todo>> _mapListToTodos(
    Database db,
    List<Map<String, dynamic>> maps,
  ) async {
    final todos = <Todo>[];
    for (final map in maps) {
      final tags = await _getTagsForTodo(db, map['id'] as String);
      todos.add(_mapToTodo(map, tags));
    }
    return todos;
  }
}

