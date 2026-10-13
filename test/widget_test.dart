// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_avicola/main.dart';
import 'package:app_avicola/routes.dart';

const _routes = [
  AppRoutes.login,
  AppRoutes.dashboard,
  AppRoutes.users,
  AppRoutes.lotes,
  AppRoutes.produccion,
  AppRoutes.clasificacion,
  AppRoutes.mortalidad,
  AppRoutes.morbilidad,
  AppRoutes.tratamiento,
  AppRoutes.reportes,
  AppRoutes.finanzas,
  AppRoutes.notificaciones,
  AppRoutes.profile,
  AppRoutes.configuracion,
];

Future<void> _visitAllRoutes(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final frameworkErrors = <FlutterErrorDetails>[];
  final previousErrorHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    frameworkErrors.add(details);
    previousErrorHandler?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousErrorHandler);

  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  final initialException = tester.takeException();
  if (frameworkErrors.isNotEmpty) {
    debugPrint(frameworkErrors.map((error) => error.toString()).join('\n'));
    frameworkErrors.clear();
  }
  if (initialException != null) debugPrint(initialException.toString());
  expect(initialException, isNull, reason: 'Initial route at $size');

  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  for (final route in _routes) {
    navigator.pushReplacementNamed(route);
    await tester.pumpAndSettle();
    final exception = tester.takeException();
    if (frameworkErrors.isNotEmpty) {
      debugPrint(frameworkErrors.map((error) => error.toString()).join('\n'));
      frameworkErrors.clear();
    }
    if (exception != null) debugPrint(exception.toString());
    expect(exception, isNull, reason: 'Route $route failed');
    if (AppRoutes.titles.containsKey(route)) {
      expect(
        find.text(AppRoutes.titles[route]!),
        findsWidgets,
        reason: 'Route $route did not render its title',
      );
    }
  }
}

void main() {
  testWidgets('all app routes build on desktop', (WidgetTester tester) async {
    await _visitAllRoutes(tester, const Size(1440, 1000));
  });

  testWidgets('all app routes build on mobile', (WidgetTester tester) async {
    await _visitAllRoutes(tester, const Size(390, 844));
  });

  testWidgets('landing module card opens its matching screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    final module = find.text('Control de Producción');
    await tester.ensureVisible(module);
    await tester.tap(module);
    await tester.pumpAndSettle();

    expect(find.text('Producción Diaria'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password recovery explains current service availability', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed(AppRoutes.login);
    await tester.pumpAndSettle();

    final recovery = find.text('¿Olvidaste tu contraseña?');
    await tester.ensureVisible(recovery);
    await tester.tap(recovery);
    await tester.pumpAndSettle();

    expect(find.text('Recuperar contraseña'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
