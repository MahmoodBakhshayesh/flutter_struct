import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:struct2/widgets/global_failure_listener.dart';
import 'core/navigation/router.dart';
import 'ui/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return GlobalFailureListener(
      child: MaterialApp.router(
        builder: BotToastInit(),
        debugShowCheckedModeBanner: false,
        title: 'My App',
        theme: buildAppTheme(),
        routerConfig: router,
        // Better scroll on web/desktop (mouse drag, trackpad, etc.).
        scrollBehavior: const _AppScrollBehavior(),
      ),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.stylus, PointerDeviceKind.trackpad, PointerDeviceKind.unknown};
}
