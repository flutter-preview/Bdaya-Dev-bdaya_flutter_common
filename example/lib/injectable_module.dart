import 'package:go_router/go_router.dart';

import 'common.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  GoRouter getRouter(GoRouterRefreshService goRouterRefreshService) => GoRouter(
        observers: [
          // seoRouteObserver,
        ],
        initialLocation: AppRouteNames.initialRoute,
        // redirect: (context, state) {
        //   // if (state.location == '/') {
        //   //   return initialRoute;
        //   // }
        //   return null;
        // },
        refreshListenable: goRouterRefreshService,
        routes: appRoutesList(),
      );
}
