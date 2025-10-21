// lib/core/failure/failure_presenter.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import '../abstracts/base_failure.dart';
import '../navigation/navigation_service.dart'; // adjust import to your structure

abstract class FailurePresenter {
  static BuildContext? get _ctx => NavigationService.rootContext;
  static NavigatorState? get _nav => NavigationService.navigator;

  static void show(FailureNotice n) {
    switch (n.severity) {
      case FailureSeverity.info:
        _showSnack(n, bg: Colors.blueAccent);
        break;
      case FailureSeverity.warning:
        _showSnack(n, bg: Colors.orangeAccent);
        break;
      case FailureSeverity.error:
        _showToast(n);
        break;
      case FailureSeverity.critical:
        _showDialog(n);
        break;
    }
  }

  static void _showSnack(FailureNotice n, {required Color bg}) {
    final ctx = _ctx;
    if (ctx == null) {
      log('No context found for snackbar');
      return;
    }

    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          duration: const Duration(seconds: 6),
          content: Text('${n.failure}'),
          action: n.retry == null
              ? null
              : SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: n.retry!,
          ),
        ),
      );
  }

  static void _showToast(FailureNotice n) {
    BotToast.showAttachedWidget(
      duration: const Duration(seconds: 8),
      target: const Offset(500, 30),
      attachedBuilder: (_) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: BotToast.cleanAll,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    '${n.failure}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (n.retry != null) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      BotToast.cleanAll();
                      n.retry?.call();
                    },
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showDialog(FailureNotice n) {
    final ctx = _ctx;
    if (ctx == null) {
      log('No context found for dialog');
      return;
    }

    showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text('${n.failure}'),
        actions: [
          if (n.retry != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).maybePop();
                n.retry?.call();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).maybePop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
