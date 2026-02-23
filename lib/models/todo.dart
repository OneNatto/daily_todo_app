import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

/// ToDoモデル
@freezed
class Todo with _$Todo {
  const Todo._();

  const factory Todo({
    required String id,
    required String title,
    @Default('') String description,
    @Default(false) bool isCompleted,
    @Default(Priority.medium) Priority priority,
    String? category,
    @Default([]) List<String> tags,
    DateTime? dueDate,
    DateTime? reminderDateTime,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  /// 期限切れかどうか
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// 今日が期限かどうか
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// リマインダーが設定されているか
  bool get hasReminder => reminderDateTime != null;
}

