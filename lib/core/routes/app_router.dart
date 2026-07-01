import 'package:shim/common/pages/error_page.dart';
import 'package:shim/core/routes/routes/home_route.dart';
import 'package:shim/core/routes/routes/scripts_route.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomeRoute.home,
    debugLogDiagnostics: true,
    routes: [
      ...homeRoutes,
      ...scriptsRoutes,
      GoRoute(
        path: '/:notFound(.*)',
        builder: (context, state) {
          return ErrorPage(error: state.matchedLocation);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return ErrorPage(error: state.error ?? state.uri.toString());
    },
  );
});
