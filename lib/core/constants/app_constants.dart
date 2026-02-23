/// アプリ全体で使用する定数
class AppConstants {
  AppConstants._();

  // アプリ情報
  static const String appName = 'Daily Todo';
  static const String appVersion = '1.0.0';

  // データベース設定
  static const String databaseName = 'daily_todo.db';
  static const int databaseVersion = 1;

  // テーブル名
  static const String todoTable = 'todos';
  static const String todoTagTable = 'todo_tags';
  static const String diaryTable = 'diaries';
  static const String diaryTodoTable = 'diary_todos';

  // 通知設定
  static const String notificationChannelId = 'todo_reminders';
  static const String notificationChannelName = 'ToDoリマインダー';
  static const String notificationChannelDescription = 'ToDoのリマインダー通知';

  // UI設定
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxDiaryContentLength = 5000;
  static const int maxTagsPerTodo = 10;

  // デフォルト値
  static const int defaultReminderMinutesBefore = 30;

  // デフォルトカテゴリ
  static const List<String> defaultCategories = [
    '仕事',
    'プライベート',
    '買い物',
    '健康',
    '勉強',
    'その他',
  ];
}

