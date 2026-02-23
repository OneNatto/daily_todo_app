// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryImpl _$$DiaryImplFromJson(Map<String, dynamic> json) => _$DiaryImpl(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  content: json['content'] as String,
  mood: $enumDecodeNullable(_$MoodEnumMap, json['mood']) ?? Mood.neutral,
  relatedTodoIds:
      (json['relatedTodoIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$DiaryImplToJson(_$DiaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'content': instance.content,
      'mood': _$MoodEnumMap[instance.mood]!,
      'relatedTodoIds': instance.relatedTodoIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MoodEnumMap = {
  Mood.veryBad: 'veryBad',
  Mood.bad: 'bad',
  Mood.neutral: 'neutral',
  Mood.good: 'good',
  Mood.veryGood: 'veryGood',
};
