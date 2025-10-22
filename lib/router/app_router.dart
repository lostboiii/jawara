import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/activity_log_page.dart';
import '../pages/user_list_page.dart';

class AppRoutes {
  static const home = '/';
  static const activityLog = '/activity-log';
  static const userList = '/user-list';
}

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.activityLog,
      name: 'activity-log',
      builder: (context, state) => const ActivityLogPage(),
    ),
    GoRoute(
      path: AppRoutes.userList,
      name: 'user-list',
      builder: (context, state) => const UserListPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const Center(child: Text('404 - Page not found')),
  ),
);
