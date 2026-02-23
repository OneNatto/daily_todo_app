import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/todo_tab.dart';
import '../../screens/home/diary_tab.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../screens/todo/todo_detail_screen.dart';
import '../../screens/diary/diary_edit_screen.dart';

/// グローバルナビゲーションキー
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/todos',
    routes: [
      // ShellRoute: BottomNavigationBar付きのメイン画面
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          // ToDo タブ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/todos',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TodoTab(),
                ),
              ),
            ],
          ),
          // 日記 タブ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diary',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DiaryTab(),
                ),
              ),
            ],
          ),
          // カレンダー タブ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CalendarScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ToDo詳細/作成画面
      GoRoute(
        path: '/todo/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final todoId = state.pathParameters['id'];
          return TodoDetailScreen(todoId: todoId);
        },
      ),

      // 日記編集画面
      GoRoute(
        path: '/diary/:date',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final dateStr = state.pathParameters['date']!;
          final parts = dateStr.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return DiaryEditScreen(date: date);
        },
      ),
    ],
  );
});

