import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../models/enums.dart';
import '../../core/utils/date_utils.dart';

/// ToDoリストアイテム
class TodoListItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const TodoListItem({
    super.key,
    required this.todo,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('削除確認'),
            content: const Text('このToDoを削除しますか？'),
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
      },
      onDismissed: (direction) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 完了チェックボックス
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => onToggleComplete?.call(),
                  shape: const CircleBorder(),
                ),
                const SizedBox(width: 8),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // メタ情報
                      Row(
                        children: [
                          // 優先度
                          _PriorityBadge(priority: todo.priority),
                          if (todo.category != null) ...[
                            const SizedBox(width: 8),
                            // カテゴリ
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                todo.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                              ),
                            ),
                          ],
                          if (todo.dueDate != null) ...[
                            const SizedBox(width: 8),
                            // 期限
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: todo.isOverdue
                                  ? colorScheme.error
                                  : colorScheme.outline,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              AppDateUtils.formatRelativeDate(todo.dueDate!),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: todo.isOverdue
                                        ? colorScheme.error
                                        : colorScheme.outline,
                                  ),
                            ),
                          ],
                          if (todo.hasReminder) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.notifications_outlined,
                              size: 14,
                              color: colorScheme.outline,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // 矢印
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.outline,
                ),
              ],
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    Color color;
    IconData icon;

    switch (priority) {
      case Priority.high:
        color = colorScheme.error;
        icon = Icons.arrow_upward;
        break;
      case Priority.medium:
        color = colorScheme.tertiary;
        icon = Icons.remove;
        break;
      case Priority.low:
        color = colorScheme.outline;
        icon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            priority.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

