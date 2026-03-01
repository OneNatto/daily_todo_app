import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/providers.dart';

/// カレンダー画面
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diaryDatesAsync = ref.watch(
      diaryDatesProvider(DateTime(_focusedDay.year, _focusedDay.month)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // カレンダー
          diaryDatesAsync.when(
            data: (diaryDates) {
              return TableCalendar(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                locale: 'ja_JP',
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                  markerDecoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                eventLoader: (day) {
                  // 日記がある日にマーカーを表示
                  final hasEntry = diaryDates.any((d) =>
                      d.year == day.year &&
                      d.month == day.month &&
                      d.day == day.day);
                  return hasEntry ? [day] : [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  ref.read(selectedDateProvider.notifier).state = selectedDay;
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
              );
            },
            loading: () => const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SizedBox(
              height: 300,
              child: Center(child: Text('エラー: $error')),
            ),
          ),

          const Divider(),

          // 選択日の詳細
          if (_selectedDay != null)
            Expanded(
              child: _SelectedDayDetails(selectedDay: _selectedDay!),
            ),
        ],
      ),
    );
  }
}

/// 選択日の詳細
class _SelectedDayDetails extends ConsumerWidget {
  final DateTime selectedDay;

  const _SelectedDayDetails({required this.selectedDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryAsync = ref.watch(selectedDateDiaryProvider);
    final todosAsync = ref.watch(selectedDateTodosProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final dateStr = '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 日記セクション
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '日記',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => context.push('/diary/$dateStr'),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('編集'),
            ),
          ],
        ),
        diaryAsync.when(
          data: (diary) {
            if (diary == null) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('この日の日記はありません'),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.push('/diary/$dateStr'),
                        child: const Text('日記を書く'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          diary.mood.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          diary.mood.label,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diary.content,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('エラー: $error'),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ToDoセクション
        Text(
          'この日のToDo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        todosAsync.when(
          data: (todos) {
            if (todos.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: const Text('この日のToDoはありません'),
                ),
              );
            }

            return Card(
              child: Column(
                children: todos.map((todo) {
                  return ListTile(
                    leading: Icon(
                      todo.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: todo.isCompleted
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: todo.category != null
                        ? Text(todo.category!)
                        : null,
                    onTap: () => context.push('/todo/${todo.id}'),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('エラー: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

