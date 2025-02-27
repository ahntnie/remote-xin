// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'core/configs/all.dart';
import 'core/utils/all.dart';

Future<void> main() async {
  await runZonedGuarded(_runMyApp, _reportError);
}

Future<void> _runMyApp() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Show splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await configureApp();
  // Remove splash screen after configure app
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

void _reportError(Object error, StackTrace stackTrace) {
  LogUtil.e('', error: error, stackTrace: stackTrace);
  // report by Firebase Crashlytics here
}
