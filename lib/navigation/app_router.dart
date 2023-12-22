import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jellyflix/models/screen_paths.dart';
import 'package:jellyflix/providers/auth_provider.dart';
import 'package:jellyflix/screens/detail_screen.dart';
import 'package:jellyflix/screens/home_screen.dart';
import 'package:jellyflix/screens/loading_screen.dart';
import 'package:jellyflix/screens/login_screen.dart';
import 'package:jellyflix/screens/profile_screen.dart';
import 'package:jellyflix/screens/search_screen.dart';
import 'package:jellyflix/screens/player_screen.dart';

class AppRouter {
  GoRouter get router => _goRouter;

  late Ref _ref;

  AppRouter(Ref ref) {
    _ref = ref;
  }

  late final GoRouter _goRouter = GoRouter(
    initialLocation: ScreenPaths.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: ScreenPaths.home,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: ScreenPaths.library,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: ScreenPaths.detail,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: DetailScreen(
            itemId: state.uri.queryParameters['id']!,
            selectedIndex:
                int.parse(state.uri.queryParameters['selectedIndex']!),
          ),
        ),
      ),
      GoRoute(
        path: ScreenPaths.player,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: PlayerScreen(itemId: state.uri.queryParameters['id']!),
        ),
      ),
      GoRoute(
        path: ScreenPaths.search,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: ScreenPaths.profile,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
          path: ScreenPaths.login,
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: const LoginScreen(),
              ))
    ],
    errorBuilder: (context, state) {
      //TODO Add 404 screen
      return const LoadingScreen();
    },
    redirect: (context, state) async {
      final isGoingToLogin = state.matchedLocation == ScreenPaths.login;
      final loggedIn = await _ref.watch(authProvider).checkAuthentication();
      if (isGoingToLogin && loggedIn) {
        return ScreenPaths.home;
      } else if (!isGoingToLogin && !loggedIn) {
        return ScreenPaths.login;
      }
      return null;
    },
    //refreshListenable: GoRouterRefreshStream(_ref),
  );

  CustomTransitionPage buildPageWithDefaultTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  final Ref _ref;
  late final Stream<bool> authState;
  GoRouterRefreshStream(this._ref) {
    notifyListeners();
    authState = _ref.read(authProvider).authStateChange;
    authState.listen((event) {
      notifyListeners();
    });
  }
}