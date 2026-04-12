import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gopaddler_flutter/presentation/pages/home_page.dart';
import 'package:gopaddler_flutter/presentation/pages/sessions_page.dart';
import 'package:gopaddler_flutter/presentation/pages/session_active_page.dart';
import 'package:gopaddler_flutter/presentation/pages/session_summary_page.dart';
import 'package:gopaddler_flutter/presentation/pages/settings_page.dart';
import 'package:gopaddler_flutter/presentation/pages/bluetooth_page.dart';
import 'package:gopaddler_flutter/presentation/pages/calibration_page.dart';

/// Main app router configuration
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: <GoRoute>[
        GoRoute(
          path: 'sessions',
          builder: (BuildContext context, GoRouterState state) {
            return const SessionsPage();
          },
        ),
        GoRoute(
          path: 'session/active',
          builder: (BuildContext context, GoRouterState state) {
            return const SessionActivePage();
          },
        ),
        GoRoute(
          path: 'session/summary/:sessionId',
          builder: (BuildContext context, GoRouterState state) {
            final sessionId = state.pathParameters['sessionId'] ?? '';
            return SessionSummaryPage(sessionId: sessionId);
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPage();
          },
        ),
        GoRoute(
          path: 'bluetooth',
          builder: (BuildContext context, GoRouterState state) {
            return const BluetoothPage();
          },
        ),
        GoRoute(
          path: 'calibration',
          builder: (BuildContext context, GoRouterState state) {
            return const CalibrationPage();
          },
        ),
      ],
    ),
  ],
);
