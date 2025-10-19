import 'package:riverpod/riverpod.dart';
import 'package:struct2/screens/passenger_details/passenger_details_controller.dart';

final passengerDetailsControllerProvider = Provider.autoDispose.family<PassengersDetailsController, DateTime>((ref, date) {
  final controller = PassengersDetailsController(ref, date);
  ref.onDispose(controller.onDispose);
  Future.microtask(controller.onInit);
  return controller;
});
