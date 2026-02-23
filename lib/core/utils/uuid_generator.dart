import 'package:uuid/uuid.dart';

/// UUID生成ユーティリティ
class UuidGenerator {
  UuidGenerator._();

  static const Uuid _uuid = Uuid();

  /// 新しいUUID v4を生成
  static String generate() => _uuid.v4();
}

