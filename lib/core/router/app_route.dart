class AppRoute {
  const AppRoute({required this.name, required this.path});
  final String name;
  final String path;
}

class AppRoutes {
  static const AppRoute home = AppRoute(name: 'home', path: '/');

  static const AppRoute logDetail = AppRoute(
    name: 'logDetail',
    path: '/log/:id',
  );

  static const AppRoute settings = AppRoute(
    name: 'settings',
    path: '/settings',
  );

  static String logDetailWithId(String id) => '/log/$id';

  static List<AppRoute> get allRoutes => [home, logDetail, settings];
}
