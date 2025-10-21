import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:struct2/core/abstracts/base_result.dart';
import 'package:struct2/core/logger/logger_service.dart';
import 'package:struct2/screens/passenger_details/passenger_details_repository.dart';
import 'package:struct2/screens/passenger_details/usecases/get_passenger_by_id_usecase.dart';
import '../../core/abstracts/base_controller.dart';
import '../../core/abstracts/base_failure.dart';
import '../../core/classes/passenger_class.dart';
import '../../core/navigation/routes.dart';
import '../../core/networking/network_manager.dart';
import '../passengers/passengers_repository.dart';
import 'passenger_details_view_state.dart';

/// Business logic for the Passengers List view.
/// - Handles loading, refresh, and navigation to details.
/// - No state is stored here; it updates the Notifier only.
class PassengerDetailsController extends BaseController {
  PassengerDetailsController(this.ref, this.viewStateNotifier, {required this.date, required this.id});

  final PassengerDetailsRepository repo = PassengerDetailsRepository(); // injected repo

  final Ref ref;
  final DateTime date;
  final String id;
  final PassengerDetailsViewNotifier viewStateNotifier;

  @override
  Future<void> onInit() async {
    logW('onInit • date=$date');
    await load();
  }

  /// Fetch passengers for [date].
  Future<void> load() async {
    final response = await GetPassengerDetailsByIdUseCase(repo).call(GetPassengerDetailsByIDRequest(id: id, date: date));
    response.onOk((ok) => viewStateNotifier.setData(ok.passenger));
    response.onErr((err) => FailureBus.I.emit(FailureNotice(failure: err)));
  }

  Future<void> refresh() => load();

  /// Navigate to passenger details (nested under /passengers/detail using query params).

  @override
  Future<void> onDispose() async {
    logW('onDispose');
    await super.onDispose();
  }
}
