// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Diary _$DiaryFromJson(Map<String, dynamic> json) {
  return _Diary.fromJson(json);
}

/// @nodoc
mixin _$Diary {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  Mood get mood => throw _privateConstructorUsedError;
  List<String> get relatedTodoIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Diary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryCopyWith<Diary> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryCopyWith<$Res> {
  factory $DiaryCopyWith(Diary value, $Res Function(Diary) then) =
      _$DiaryCopyWithImpl<$Res, Diary>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    String content,
    Mood mood,
    List<String> relatedTodoIds,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$DiaryCopyWithImpl<$Res, $Val extends Diary>
    implements $DiaryCopyWith<$Res> {
  _$DiaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? content = null,
    Object? mood = null,
    Object? relatedTodoIds = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as Mood,
            relatedTodoIds: null == relatedTodoIds
                ? _value.relatedTodoIds
                : relatedTodoIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiaryImplCopyWith<$Res> implements $DiaryCopyWith<$Res> {
  factory _$$DiaryImplCopyWith(
    _$DiaryImpl value,
    $Res Function(_$DiaryImpl) then,
  ) = __$$DiaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    String content,
    Mood mood,
    List<String> relatedTodoIds,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$DiaryImplCopyWithImpl<$Res>
    extends _$DiaryCopyWithImpl<$Res, _$DiaryImpl>
    implements _$$DiaryImplCopyWith<$Res> {
  __$$DiaryImplCopyWithImpl(
    _$DiaryImpl _value,
    $Res Function(_$DiaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? content = null,
    Object? mood = null,
    Object? relatedTodoIds = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DiaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as Mood,
        relatedTodoIds: null == relatedTodoIds
            ? _value._relatedTodoIds
            : relatedTodoIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryImpl extends _Diary {
  const _$DiaryImpl({
    required this.id,
    required this.date,
    required this.content,
    this.mood = Mood.neutral,
    final List<String> relatedTodoIds = const [],
    required this.createdAt,
    this.updatedAt,
  }) : _relatedTodoIds = relatedTodoIds,
       super._();

  factory _$DiaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String content;
  @override
  @JsonKey()
  final Mood mood;
  final List<String> _relatedTodoIds;
  @override
  @JsonKey()
  List<String> get relatedTodoIds {
    if (_relatedTodoIds is EqualUnmodifiableListView) return _relatedTodoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedTodoIds);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Diary(id: $id, date: $date, content: $content, mood: $mood, relatedTodoIds: $relatedTodoIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            const DeepCollectionEquality().equals(
              other._relatedTodoIds,
              _relatedTodoIds,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    content,
    mood,
    const DeepCollectionEquality().hash(_relatedTodoIds),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryImplCopyWith<_$DiaryImpl> get copyWith =>
      __$$DiaryImplCopyWithImpl<_$DiaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryImplToJson(this);
  }
}

abstract class _Diary extends Diary {
  const factory _Diary({
    required final String id,
    required final DateTime date,
    required final String content,
    final Mood mood,
    final List<String> relatedTodoIds,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$DiaryImpl;
  const _Diary._() : super._();

  factory _Diary.fromJson(Map<String, dynamic> json) = _$DiaryImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get content;
  @override
  Mood get mood;
  @override
  List<String> get relatedTodoIds;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryImplCopyWith<_$DiaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
