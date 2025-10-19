import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:struct2/core/logger/logger_service.dart';
import '../../core/abstracts/base_controller.dart';
import '../../core/classes/passenger_class.dart';
import '../../core/navigation/routes.dart';
import '../../core/networking/network_manager.dart';

/// Business logic for the Passengers List view.
/// - Handles loading, refresh, and navigation to details.
/// - No state is stored here; it updates the Notifier only.
class PassengersDetailsController extends BaseController {
  PassengersDetailsController(this.ref, this.date);

  final Ref ref;
  final DateTime date;

  @override
  Future<void> onInit() async {
    logW('onInit • date=$date');
    await load();
  }

  /// Fetch passengers for [date].
  Future<void> load() async {

  }

  Future<void> refresh() => load();

  /// Navigate to passenger details (nested under /passengers/detail using query params).

  @override
  Future<void> onDispose() async {
    logW('onDispose');
    await super.onDispose();
  }
}
