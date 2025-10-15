import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:struct2/bootstrap.dart';

import 'my_app.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await bootstrap();
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      log(error.toString());
      // Report the error here (Crashlytics/Sentry/etc.)
      // FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}
