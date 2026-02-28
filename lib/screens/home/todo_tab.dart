import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/todo.dart';
import '../../models/enums.dart';

/// ToDoタブ
class TodoTab extends ConsumerWidget {
  const TodoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _TodoSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // フィルターチップ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: TodoFilter.values.map((f) {
                final isSelected = f == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.label),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(todoFilterProvider.notifier).state = f;
                      ref.read(todoListProvider.notifier).refresh();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // ToDoリスト
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filter == TodoFilter.completed
                              ? '完了したToDoはありません'
                              : filter == TodoFilter.active
                                  ? '未完了のToDoはありません'
                                  : 'ToDoがありません',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '右下のボタンから追加しましょう',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(todoListProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return _TodoCard(todo: todo);
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
                      onPressed: () => ref.read(todoListProvider.notifier).refresh(),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/todo/new'),
        icon: const Icon(Icons.add),
        label: const Text('ToDo追加'),
      ),
    );
  }
}

/// ToDoカード
class _TodoCard extends ConsumerWidget {
  final Todo todo;

  const _TodoCard({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => context.push('/todo/${todo.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // チェックボックス
              IconButton(
                icon: Icon(
                  todo.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: todo.isCompleted
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
                onPressed: () {
                  ref.read(todoListProvider.notifier).toggleCompletion(todo.id);
                },
              ),

              // コンテンツ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      todo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? colorScheme.outline
                                : null,
                          ),
                    ),

                    const SizedBox(height: 4),

                    // 説明（あれば）
                    if (todo.description.isNotEmpty)
                      Text(
                        todo.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                      ),

                    const SizedBox(height: 8),

                    // メタ情報
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // 優先度
                        _PriorityBadge(priority: todo.priority),

                        // カテゴリ
                        if (todo.category != null)
                          Chip(
                            label: Text(todo.category!),
                            labelStyle: const TextStyle(fontSize: 10),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),

                        // 期限日
                        if (todo.dueDate != null)
                          _DueDateBadge(
                            dueDate: todo.dueDate!,
                            isOverdue: todo.isOverdue,
                            isCompleted: todo.isCompleted,
                          ),

                        // リマインダー
                        if (todo.hasReminder)
                          Icon(
                            Icons.notifications_active,
                            size: 16,
                            color: colorScheme.tertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 優先度バッジ
class _PriorityBadge extends StatelessWidget {
  final Priority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      Priority.high => Colors.red,
      Priority.medium => Colors.orange,
      Priority.low => Colors.green,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 期限日バッジ
class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool isOverdue;
  final bool isCompleted;

  const _DueDateBadge({
    required this.dueDate,
    required this.isOverdue,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? Theme.of(context).colorScheme.outline
        : isOverdue
            ? Colors.red
            : Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '${dueDate.month}/${dueDate.day}',
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }
}

/// ToDo検索デリゲート
class _TodoSearchDelegate extends SearchDelegate<String?> {
  final WidgetRef ref;

  _TodoSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'ToDoを検索';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('検索キーワードを入力してください'));
    }

    // 検索クエリを設定して再取得
    ref.read(todoSearchQueryProvider.notifier).state = query;
    ref.read(todoListProvider.notifier).refresh();

    final todosAsync = ref.watch(todoListProvider);

    return todosAsync.when(
      data: (todos) {
        final filteredTodos = todos.where((todo) =>
            todo.title.toLowerCase().contains(query.toLowerCase()) ||
            todo.description.toLowerCase().contains(query.toLowerCase())).toList();

        if (filteredTodos.isEmpty) {
          return const Center(child: Text('該当するToDoが見つかりません'));
        }

        return ListView.builder(
          itemCount: filteredTodos.length,
          itemBuilder: (context, index) {
            final todo = filteredTodos[index];
            return ListTile(
              leading: Icon(
                todo.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
              title: Text(todo.title),
              subtitle: todo.description.isNotEmpty
                  ? Text(todo.description, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : null,
              onTap: () {
                close(context, null);
                context.push('/todo/${todo.id}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('エラー: $error')),
    );
  }
}

