import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:afya_id/ui/views/login/login_page.dart';
import 'package:afya_id/ui/views/login/onboarding_page.dart';
import 'package:afya_id/ui/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/ui.dart';

import 'routes.dart';

GoRoute hostRoute = GoRoute(
  path: RoutesPaths.host,
  name: RoutesNames.host,
  builder: (context, state) {
    return HostPage();
  },
);
GoRoute onBoardingRoute = GoRoute(
  path: RoutesPaths.initial,
  name: RoutesNames.initial,
  builder: (context, state) {
    final provider = Provider.of<GeneralProvider>(context);
    bool isConnected =
        provider.userModel != null && provider.userModel!.id.isNotEmpty;
    return isConnected ? HostPage() : OnboardingPage();
  },
);
GoRoute loginRoute = GoRoute(
  path: RoutesPaths.login,
  name: RoutesNames.login,
  builder: (context, state) {
    return LoginPage();
  },
);

GoRoute profileRoute = GoRoute(
  path: RoutesPaths.profile,
  name: RoutesNames.profile,
  builder: (context, state) {
    return ProfilePage();
  },
);

GoRouter goRouter = GoRouter(
  initialLocation:
      onBoardingRoute.path, // Start with Emergency Dashboard for MVP
  errorBuilder: (context, state) {
    return Scaffold(body: const Center(child: Text("Error")));
  },
  redirect: (context, state) async {
    return null;
  },
  routes: [
    hostRoute,
    onBoardingRoute,
    loginRoute,
    profileRoute,

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
