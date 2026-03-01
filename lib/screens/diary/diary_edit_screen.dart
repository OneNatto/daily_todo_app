import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/diary.dart';
import '../../models/enums.dart';
import '../../core/constants/app_constants.dart';

/// 日記編集画面
class DiaryEditScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const DiaryEditScreen({super.key, required this.date});

  @override
  ConsumerState<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends ConsumerState<DiaryEditScreen> {
  final _contentController = TextEditingController();
  Mood _mood = Mood.neutral;
  List<String> _selectedTodoIds = [];
  bool _isLoading = true;
  Diary? _existingDiary;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    final useCases = ref.read(diaryUseCasesProvider);
    final diary = await useCases.getDiaryByDate(widget.date);
    if (diary != null) {
      _existingDiary = diary;
      _contentController.text = diary.content;
      _mood = diary.mood;
      _selectedTodoIds = List.from(diary.relatedTodoIds);
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${widget.date.year}年${widget.date.month}月${widget.date.day}日';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('$dateStrの日記')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$dateStrの日記'),
        actions: [
          if (_existingDiary != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteDiary,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 気分選択
          Text('今日の気分', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _MoodSelector(
            selectedMood: _mood,
            onMoodSelected: (mood) => setState(() => _mood = mood),
          ),
          const SizedBox(height: 24),

          // 日記本文
          Text('日記', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              hintText: '今日の出来事を書いてください...',
              border: OutlineInputBorder(),
            ),
            maxLines: 10,
            maxLength: AppConstants.maxDiaryContentLength,
          ),
          const SizedBox(height: 24),

          // この日のToDo
          Text('この日のToDo', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _TodoCheckList(
            date: widget.date,
            selectedTodoIds: _selectedTodoIds,
            onSelectionChanged: (ids) => setState(() => _selectedTodoIds = ids),
          ),
          const SizedBox(height: 32),

          // 保存ボタン
          FilledButton.icon(
            onPressed: _saveDiary,
            icon: const Icon(Icons.save),
            label: Text(_existingDiary != null ? '更新' : '保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日記の内容を入力してください')),
      );
      return;
    }

    try {
      await ref.read(diaryListProvider.notifier).saveDiary(
            date: widget.date,
            content: _contentController.text.trim(),
            mood: _mood,
            relatedTodoIds: _selectedTodoIds,
            existingId: _existingDiary?.id,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_existingDiary != null ? '日記を更新しました' : '日記を保存しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  Future<void> _deleteDiary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この日記を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && _existingDiary != null) {
      await ref.read(diaryListProvider.notifier).deleteDiary(_existingDiary!.id);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日記を削除しました')),
        );
      }
    }
  }
}

/// 気分選択ウィジェット
class _MoodSelector extends StatelessWidget {
  final Mood selectedMood;
  final ValueChanged<Mood> onMoodSelected;

  const _MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: Mood.values.map((mood) {
        final isSelected = mood == selectedMood;
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  mood.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// この日のToDoチェックリスト
class _TodoCheckList extends ConsumerWidget {
  final DateTime date;
  final List<String> selectedTodoIds;
  final ValueChanged<List<String>> onSelectionChanged;

  const _TodoCheckList({
    required this.date,
    required this.selectedTodoIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(selectedDateTodosProvider);

    // selectedDateProviderを更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedDateProvider.notifier).state = date;
    });

    return todosAsync.when(
      data: (todos) {
        if (todos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('この日のToDoはありません'),
          );
        }

        return Column(
          children: todos.map((todo) {
            final isSelected = selectedTodoIds.contains(todo.id);
            return CheckboxListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: todo.category != null ? Text(todo.category!) : null,
              value: isSelected,
              onChanged: (value) {
                final newList = List<String>.from(selectedTodoIds);
                if (value == true) {
                  newList.add(todo.id);
                } else {
                  newList.remove(todo.id);
                }
                onSelectionChanged(newList);
              },
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('エラー: $error'),
    );
  }
}

