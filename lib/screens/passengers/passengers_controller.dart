import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:struct2/core/logger/logger_service.dart';
import '../../core/abstracts/base_controller.dart';
import '../../core/classes/passenger_class.dart';
import '../../core/navigation/routes.dart';
import '../../core/networking/network_manager.dart';
import 'passengers_view_state.dart';

/// Business logic for the Passengers List view.
/// - Handles loading, refresh, and navigation to details.
/// - No state is stored here; it updates the Notifier only.
class PassengersController extends BaseController {
  PassengersController(this.ref, this._notifier, this.date);

  final Ref ref;
  final PassengersListNotifier _notifier;
  final DateTime date;

  @override
  Future<void> onInit() async {
    logW('onInit • date=$date');
    await load();
  }

  /// Fetch passengers for [date].
  Future<void> load() async {
    try {
      _notifier.setLoading();

      final nm = NetworkManager.instance;
      final res = await nm.get('/passengers', query: {'date': date.toIso8601String()});

      final list = (res.data as List).cast<Map<String, dynamic>>().map(Passenger.fromJson).toList();

      _notifier.setData(list);
    } catch (e, st) {
      logE('load failed', e, st);
      _notifier.setError(e.toString());
      showSnack('Failed to load passengers');
    }
  }

  /// Manual refresh (e.g., pull-to-refresh or retry).
  Future<void> refresh() => load();

  /// Navigate to passenger details (nested under /passengers/detail using query params).
  void goToDetails({required String passengerId}) {
    try {
      final uri = Uri(path: "/passengers/passenger-details", queryParameters: Routes.qPassenger(date, passengerId)).toString();
      push(uri); // or go(uri) if you want to replace
    }catch(e){
      log(e.toString());
    }
  }

  @override
  Future<void> onDispose() async {
    logW('onDispose');
    await super.onDispose();
  }
}
