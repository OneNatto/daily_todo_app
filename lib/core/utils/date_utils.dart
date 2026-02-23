import 'package:intl/intl.dart';

/// 日付関連のユーティリティ
class AppDateUtils {
  AppDateUtils._();

  // フォーマッター
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _displayDateFormat = DateFormat('M月d日(E)', 'ja_JP');
  static final DateFormat _displayDateTimeFormat = DateFormat('M月d日(E) HH:mm', 'ja_JP');
  static final DateFormat _monthFormat = DateFormat('yyyy年M月', 'ja_JP');

  /// 日付を文字列に変換（yyyy-MM-dd）
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// 時間を文字列に変換（HH:mm）
  static String formatTime(DateTime time) => _timeFormat.format(time);

  /// 日時を文字列に変換（yyyy-MM-dd HH:mm）
  static String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);

  /// 表示用の日付文字列（M月d日(E)）
  static String formatDisplayDate(DateTime date) => _displayDateFormat.format(date);

  /// 表示用の日時文字列（M月d日(E) HH:mm）
  static String formatDisplayDateTime(DateTime dateTime) => _displayDateTimeFormat.format(dateTime);

  /// 月表示用（yyyy年M月）
  static String formatMonth(DateTime date) => _monthFormat.format(date);

  /// 文字列から日付に変換
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _dateFormat.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  /// 文字列から日時に変換
  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return _dateTimeFormat.parse(dateTimeString);
    } catch (_) {
      return null;
    }
  }

  /// 今日の0時0分を取得
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 指定日の0時0分を取得
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 指定日の23時59分59秒を取得
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// 同じ日かどうか
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 今日かどうか
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// 明日かどうか
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// 過去かどうか（今日より前）
  static bool isPast(DateTime date) {
    return startOfDay(date).isBefore(today());
  }

  /// 相対的な日付表示（今日、明日、または日付）
  static String formatRelativeDate(DateTime date) {
    if (isToday(date)) return '今日';
    if (isTomorrow(date)) return '明日';
    return formatDisplayDate(date);
  }
}

