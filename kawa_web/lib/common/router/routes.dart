part of 'appRoutes.dart';

abstract class AppRoutes {
  static const home = '/';
  static const chat = '/chat';
  static String kitchen({required String projectID}) =>
      '/kitchen?projectID=$projectID';
  static const login = '/login';
  // static const kitchen = '/kitchen';
  static const signUp = '/signUp';
  // static String subscription({required String shopId}) =>
  //     '/subscription?shop_id=$shopId';
}

List<RouteBase> routes = <RouteBase>[
  GoRoute(
    path: '/',
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: AuthGuard(
          fallbackRoute: "/login",
          childBuilder: () {
            return HomePage();
          }),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: 'kitchen',
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: AuthGuard(
              fallbackRoute: '/login',
              childBuilder: () {
                final query = state.uri.queryParameters;
                if (query['projectID'] == null) {
                  return const NotFoundScreen();
                }
                return Kitchen(
                  projectId: query['projectID']!,
                );
              },
            )),
      ),
    ],
  ),
  GoRoute(
      path: "/login",
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: const Login(),
          ),
      routes: const []),
  GoRoute(
      path: "/signUp",
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: const SignUp(),
          ),
      routes: const []),
];

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
