import 'package:shimx/features/home/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

class HomeRoute {
  HomeRoute._();

  static const home = '/home';

}

List<GoRoute> homeRoutes = [
  GoRoute(path: HomeRoute.home, builder: (context, state) => const HomePage()),

];
