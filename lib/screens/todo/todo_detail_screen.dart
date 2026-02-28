import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/todo.dart';
import '../../models/enums.dart';
import '../../core/constants/app_constants.dart';

/// ToDo詳細/編集画面
class TodoDetailScreen extends ConsumerStatefulWidget {
  final String? todoId;

  const TodoDetailScreen({super.key, this.todoId});

  @override
  ConsumerState<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends ConsumerState<TodoDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _priority = Priority.medium;
  String? _category;
  List<String> _tags = [];
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  DateTime? _reminderDateTime;
  bool _isLoading = true;
  Todo? _existingTodo;

  bool get _isEditing => widget.todoId != null && widget.todoId != 'new';

  @override
  void initState() {
    super.initState();
    _loadTodo();
  }

  Future<void> _loadTodo() async {
    if (_isEditing) {
      final useCases = ref.read(todoUseCasesProvider);
      final todo = await useCases.getTodoById(widget.todoId!);
      if (todo != null) {
        _existingTodo = todo;
        _titleController.text = todo.title;
        _descriptionController.text = todo.description;
        _priority = todo.priority;
        _category = todo.category;
        _tags = List.from(todo.tags);
        _dueDate = todo.dueDate;
        if (todo.dueDate != null) {
          _dueTime = TimeOfDay.fromDateTime(todo.dueDate!);
        }
        _reminderDateTime = todo.reminderDateTime;
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'ToDo編集' : '新規ToDo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ToDo編集' : '新規ToDo'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTodo,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // タイトル
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル *',
                hintText: 'ToDoのタイトルを入力',
              ),
              maxLength: AppConstants.maxTitleLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 説明
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                hintText: '詳細な説明を入力',
              ),
              maxLines: 3,
              maxLength: AppConstants.maxDescriptionLength,
            ),
            const SizedBox(height: 16),

            // 優先度
            Text('優先度', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Priority>(
              segments: Priority.values.map((p) {
                return ButtonSegment(
                  value: p,
                  label: Text(p.label),
                  icon: Icon(_priorityIcon(p)),
                );
              }).toList(),
              selected: {_priority},
              onSelectionChanged: (selected) {
                setState(() => _priority = selected.first);
              },
            ),
            const SizedBox(height: 16),

            // カテゴリ
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'カテゴリ',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('なし')),
                ...AppConstants.defaultCategories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }),
              ],
              onChanged: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 16),

            // 期限日
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_dueDate != null
                  ? '${_dueDate!.year}/${_dueDate!.month}/${_dueDate!.day}'
                  : '期限日を設定'),
              subtitle: _dueTime != null
                  ? Text('${_dueTime!.hour}:${_dueTime!.minute.toString().padLeft(2, '0')}')
                  : null,
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _dueDate = null;
                        _dueTime = null;
                        _reminderDateTime = null;
                      }),
                    )
                  : null,
              onTap: _selectDueDate,
            ),
            const Divider(),

            // リマインダー
            if (_dueDate != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_outlined),
                title: Text(_reminderDateTime != null
                    ? 'リマインダー: ${_reminderDateTime!.year}/${_reminderDateTime!.month}/${_reminderDateTime!.day} ${_reminderDateTime!.hour}:${_reminderDateTime!.minute.toString().padLeft(2, '0')}'
                    : 'リマインダーを設定'),
                trailing: _reminderDateTime != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _reminderDateTime = null),
                      )
                    : null,
                onTap: _selectReminder,
              ),

            const SizedBox(height: 32),

            // 保存ボタン
            FilledButton.icon(
              onPressed: _saveTodo,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? '更新' : '作成'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _priorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? TimeOfDay.now(),
      );

      setState(() {
        _dueDate = date;
        _dueTime = time;
      });
    }
  }

  Future<void> _selectReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _dueDate ?? DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _reminderDateTime != null
            ? TimeOfDay.fromDateTime(_reminderDateTime!)
            : TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _reminderDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? fullDueDate;
    if (_dueDate != null) {
      fullDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime?.hour ?? 23,
        _dueTime?.minute ?? 59,
      );
    }

    try {
      if (_isEditing && _existingTodo != null) {
        final updatedTodo = _existingTodo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          category: _category,
          tags: _tags,
          dueDate: fullDueDate,
          reminderDateTime: _reminderDateTime,
        );
        await ref.read(todoListProvider.notifier).updateTodo(updatedTodo);
      } else {
        await ref.read(todoListProvider.notifier).addTodo(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              priority: _priority,
              category: _category,
              tags: _tags,
              dueDate: fullDueDate,
              reminderDateTime: _reminderDateTime,
            );
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'ToDoを更新しました' : 'ToDoを作成しました')),
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

  Future<void> _deleteTodo() async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true && widget.todoId != null) {
      await ref.read(todoListProvider.notifier).deleteTodo(widget.todoId!);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ToDoを削除しました')),
        );
      }
    }
  }
}

