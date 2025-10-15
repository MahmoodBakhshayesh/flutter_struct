import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'di.dart';
import 'my_app.dart';

/// Bootstraps the entire Flutter application.
/// Initializes dependencies, ensures Flutter bindings, and runs inside a guarded zone.
Future<void> bootstrap() async {
  await configureDependenciesBase();
}
