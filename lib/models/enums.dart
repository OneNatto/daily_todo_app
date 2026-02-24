/// 優先度の列挙型
enum Priority {
  low(0, '低'),
  medium(1, '中'),
  high(2, '高');

  const Priority(this.value, this.label);

  final int value;
  final String label;

  /// intからPriorityに変換
  static Priority fromValue(int value) {
    return Priority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Priority.medium,
    );
  }
}

/// 気分の列挙型
enum Mood {
  veryBad(1, '😢', 'とても悪い'),
  bad(2, '😔', '悪い'),
  neutral(3, '😐', '普通'),
  good(4, '🙂', '良い'),
  veryGood(5, '😄', 'とても良い');

  const Mood(this.value, this.emoji, this.label);

  final int value;
  final String emoji;
  final String label;

  /// intからMoodに変換
  static Mood fromValue(int value) {
    return Mood.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Mood.neutral,
    );
  }
}

/// ToDoフィルターの列挙型
enum TodoFilter {
  all('すべて'),
  active('未完了'),
  completed('完了済み'),
  today('今日'),
  overdue('期限切れ');

  const TodoFilter(this.label);

  final String label;
}

/// ToDoソート基準の列挙型
enum TodoSortBy {
  createdAt('作成日'),
  dueDate('期限日'),
  priority('優先度'),
  title('タイトル');

  const TodoSortBy(this.label);

  final String label;
}

/// ソート順序の列挙型
enum SortOrder {
  ascending('昇順'),
  descending('降順');

  const SortOrder(this.label);

  final String label;
}

