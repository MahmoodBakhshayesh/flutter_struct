import 'package:riverpod/riverpod.dart';
import 'package:struct2/screens/passenger_details/passenger_details_controller.dart';

import 'passenger_details_view_state.dart';

final passengerDetailsControllerProvider = Provider.autoDispose.family<PassengerDetailsController, (String, DateTime)>((ref, (String id, DateTime date) args) {
    final notifier = ref.read(passengerDetailsViewStateProvider(args).notifier);
    final controller = PassengerDetailsController(ref,notifier,id: args.$1,date: args.$2);
    ref.onDispose(controller.onDispose);
    Future.microtask(controller.onInit);
    return controller;
});
