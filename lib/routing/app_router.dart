import 'package:go_router/go_router.dart';

import 'package:gymapp/screens/home_screen.dart';
import 'package:gymapp/screens/workouts_screen.dart';
import 'package:gymapp/widgets/bottom_navigation_scaffold.dart';

class AppRouter {
  static const String home = '/';
  static const String workouts = '/workouts';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavigationScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: workouts,
                builder: (context, state) => const WorkoutsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
