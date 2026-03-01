import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/diary.dart';
import '../../models/enums.dart';

/// 日記タブ
class DiaryTab extends ConsumerWidget {
  const DiaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diariesAsync = ref.watch(diaryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('日記'),
      ),
      body: diariesAsync.when(
        data: (diaries) {
          if (diaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '日記がありません',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下のボタンから今日の日記を書きましょう',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          // 日付降順でソート
          final sortedDiaries = List<Diary>.from(diaries)
            ..sort((a, b) => b.date.compareTo(a.date));

          return RefreshIndicator(
            onRefresh: () => ref.read(diaryListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: sortedDiaries.length,
              itemBuilder: (context, index) {
                final diary = sortedDiaries[index];
                return _DiaryCard(diary: diary);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('エラー: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.read(diaryListProvider.notifier).refresh(),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final now = DateTime.now();
          final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          context.push('/diary/$dateStr');
        },
        icon: const Icon(Icons.edit),
        label: const Text('今日の日記'),
      ),
    );
  }
}

/// 日記カード
class _DiaryCard extends StatelessWidget {
  final Diary diary;

  const _DiaryCard({required this.diary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = '${diary.date.year}-${diary.date.month.toString().padLeft(2, '0')}-${diary.date.day.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => context.push('/diary/$dateStr'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日付と気分
              Row(
                children: [
                  // 気分emoji
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      diary.mood.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 日付
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${diary.date.year}年${diary.date.month}月${diary.date.day}日',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _getWeekdayName(diary.date.weekday),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // 気分ラベル
                  Chip(
                    label: Text(diary.mood.label),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 本文プレビュー
              Text(
                diary.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // 関連ToDo数
              if (diary.relatedTodoIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 14,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${diary.relatedTodoIds.length}件のToDo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return '${weekdays[weekday - 1]}曜日';
  }
}

