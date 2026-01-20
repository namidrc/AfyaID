import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../ui/ui.dart';

import 'routes.dart';

GoRoute hostRoute = GoRoute(
  path: RoutesPaths.host,
  name: RoutesNames.host,
  builder: (context, state) {
    return HostPage();
  },
);

GoRouter goRouter = GoRouter(
  initialLocation: RoutesPaths.host,
  errorBuilder: (context, state) {
    return Center(child: Text("Error"));
  },
  redirect: (context, state) async {
    return null;
  },
  routes: [hostRoute],
);
