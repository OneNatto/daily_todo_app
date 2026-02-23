import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'diary.freezed.dart';
part 'diary.g.dart';

/// 日記モデル
@freezed
class Diary with _$Diary {
  const Diary._();

  const factory Diary({
    required String id,
    required DateTime date,
    required String content,
    @Default(Mood.neutral) Mood mood,
    @Default([]) List<String> relatedTodoIds,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Diary;

  factory Diary.fromJson(Map<String, dynamic> json) => _$DiaryFromJson(json);

  /// 日記が空かどうか
  bool get isEmpty => content.trim().isEmpty;

  /// 関連ToDoがあるかどうか
  bool get hasRelatedTodos => relatedTodoIds.isNotEmpty;
}

