// lib/features/passengers/details/passenger_details_state.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/abstracts/base_state.dart'; // defines LoadStatus { idle, loading, success, error }
import '../../core/classes/passenger_class.dart';

// sentinels to allow setting nullable fields to null via copyWith
const Object _keep = Object();
const Object _keepInt = Object();

@immutable
class PassengerDetailsViewState {
  final LoadStatus status;
  final DateTime date;
  final String id;

  // data + error
  final Passenger? passenger;
  final String? error;

  // ui-only bits
  final String? search;
  final int? selectedId;

  const PassengerDetailsViewState({required this.status, required this.date, required this.id, this.passenger, this.error, this.search, this.selectedId});

  factory PassengerDetailsViewState.initial(String id, DateTime date) => PassengerDetailsViewState(id: id, date: date, status: LoadStatus.idle);

  PassengerDetailsViewState copyWith({
    LoadStatus? status,
    DateTime? date,
    String? id,

    // use sentinels for nullable fields so callers can explicitly set null
    Object? passenger = _keep,
    Object? error = _keep,
    Object? search = _keep,
    Object? selectedId = _keepInt,
  }) {
    return PassengerDetailsViewState(
      status: status ?? this.status,
      date: date ?? this.date,
      id: id ?? this.id,
      passenger: identical(passenger, _keep) ? this.passenger : passenger as Passenger?,
      error: identical(error, _keep) ? this.error : error as String?,
      search: identical(search, _keep) ? this.search : search as String?,
      selectedId: identical(selectedId, _keepInt) ? this.selectedId : selectedId as int?,
    );
  }
}

class PassengerDetailsViewNotifier extends Notifier<PassengerDetailsViewState> {
  late final String _id;
  late final DateTime _date;

  PassengerDetailsViewNotifier((String id, DateTime date) args) {
    _id = args.$1;
    _date = args.$2;
  }

  @override
  PassengerDetailsViewState build() {
    return PassengerDetailsViewState(id: _id, date: _date, status: LoadStatus.loading);
  }

  String get id => _id;

  DateTime get date => _date;

  // Mutations
  void setLoading() => state = state.copyWith(status: LoadStatus.loading, error: null);

  void setData(Passenger p) => state = state.copyWith(status: LoadStatus.success, passenger: p, error: null);

  void setError(String msg) => state = state.copyWith(status: LoadStatus.error, error: msg);

  void setSearch(String? q) => state = state.copyWith(search: q);

  void setSelected(int? id) => state = state.copyWith(selectedId: id);
}

final passengerDetailsViewStateProvider = NotifierProvider.family<PassengerDetailsViewNotifier, PassengerDetailsViewState, (String, DateTime)>(PassengerDetailsViewNotifier.new);
