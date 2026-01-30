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
  initialLocation: hostRoute.path, // Start with Emergency Dashboard for MVP
  errorBuilder: (context, state) {
    return const Center(child: Text("Error"));
  },
  redirect: (context, state) async {
    return null;
  },
  routes: [
    hostRoute,
    // GoRoute(
    //   path: RoutesPaths.emergencyDashboard,
    //   name: RoutesNames.emergencyDashboard,
    //   builder: (context, state) => const EmergencyDashboard(),
    // ),
    // GoRoute(
    //   path: RoutesPaths.patientRecord,
    //   name: RoutesNames.patientRecord,
    //   builder: (context, state) {
    //     final id = state.pathParameters['id'] ?? 'unknown';
    //     return PatientVitalCard(id: id);
    //   },
    // ),
    // GoRoute(
    //   path: RoutesPaths.registration,
    //   name: RoutesNames.registration,
    //   builder: (context, state) => const RegistrationForm(),
    // ),
    // GoRoute(
    //   path: RoutesPaths.journal,
    //   name: RoutesNames.journal,
    //   builder: (context, state) => const ConsultationJournal(),
    // ),
    // GoRoute(
    //   path: RoutesPaths.auditLogs,
    //   name: RoutesNames.auditLogs,
    //   builder: (context, state) => const AuditLogs(),
    // ),
    // GoRoute(
    //   path: RoutesPaths.biometricScan,
    //   name: RoutesNames.biometricScan,
    //   builder: (context, state) {
    //     final isFace = state.extra as bool? ?? true;
    //     return BiometricScanView(isFace: isFace);
    //   },
    // ),
  ],
);
