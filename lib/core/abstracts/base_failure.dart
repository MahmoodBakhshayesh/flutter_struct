// lib/core/failure/failure_bus.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'base_result.dart';

// Your Failure base type

enum FailureSeverity { info, warning, error, critical }

class FailureNotice {
  final Failure failure;
  final FailureSeverity severity;
  final VoidCallback? retry;
  final Object? extra; // optional payload

  const FailureNotice({
    required this.failure,
    this.severity = FailureSeverity.error,
    this.retry,
    this.extra,
  });
}

class FailureBus {
  FailureBus._();
  static final FailureBus I = FailureBus._();

  final _ctrl = StreamController<FailureNotice>.broadcast(sync: true);
  Stream<FailureNotice> get stream => _ctrl.stream;

  void emit(FailureNotice n) {
    if (!_ctrl.isClosed) _ctrl.add(n);
  }

  void dispose() => _ctrl.close();
}
