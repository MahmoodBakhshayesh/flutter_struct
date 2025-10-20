import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:struct2/screens/passengers/passengers_controller.dart';
import 'package:struct2/screens/passengers/passengers_repository.dart';
import 'package:struct2/screens/passengers/passengers_view_state.dart';

import '../../core/classes/passenger_class.dart';
import '../../core/networking/network_manager.dart';

/// List passengers for a specific date
final passengersByDateProvider = FutureProvider.family<List<Passenger>, DateTime>((ref, date) async {
  // await Future.delayed(Duration(seconds: 5));
  final nm = NetworkManager.instance;
  // final res = await nm.get('/passengers', query: {'date': date.toIso8601String()});
  final res = await nm.get('/passengers');
  // Success path returns NetworkResponse; failures throw NetworkException by default.
  final list = (res.data as List).cast<Map<String, dynamic>>();
  log("got passengers list");

  return list.map((m) => Passenger.fromJson(m)).toList();
});

/// Single passenger details (id + date for cache key uniqueness)
final passengerDetailsProvider = FutureProvider.autoDispose.family<Passenger, ({DateTime date, String passengerId})>((ref, key) async {
  final loadedList = await ref.read(passengersByDateProvider(DateTime.now()).future);

  final cToken = CancelToken();
  ref.onDispose(() => cToken.cancel('route popped'));
  final nm = NetworkManager.instance;
  // final res = await nm.get('/passengers/${key.passengerId}', query: {'date': key.date.toIso8601String()});
  String api = '/passengers/${key.passengerId}';
  // log(api);
  try {
    final res = await nm.get(api, cancelToken: cToken);
    final m = (res.data as Map<String, dynamic>);
    log("got passenger details");
    return Passenger.fromJson(m);
  } catch (e) {
    log("$e");
    rethrow;
  }
});

// Controller stays the same, but read from the new name
final passengersListControllerProvider = Provider.autoDispose.family<PassengersController, DateTime>((ref, date) {
  final notifier = ref.read(passengersViewStateProvider(date).notifier);
  final controller = PassengersController(ref: ref, viewState: notifier, date: date);
  ref.onDispose(controller.onDispose);
  Future.microtask(controller.onInit);
  return controller;
});
