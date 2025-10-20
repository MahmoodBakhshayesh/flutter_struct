import 'dart:collection';

import 'package:riverpod/riverpod.dart';

import '../../core/abstracts/base_state.dart';
import '../../core/classes/passenger_class.dart';

class PassengersViewState {
  final LoadStatus status;
  final DateTime date;
  final String? error;

  // Example extra bits the view might need
  final String? search; // ui filter
  final int? selectedId; // currently highlighted row

  const PassengersViewState({required this.status, required this.date,this.error, this.search, this.selectedId});

  factory PassengersViewState.initial(DateTime date) => PassengersViewState(status: LoadStatus.idle, date: date);

  PassengersViewState copyWith({
    LoadStatus? status,
    DateTime? date,
    List<Passenger>? passengers,
    String? error,
    Object? search = _keep, // special sentinel so you can set null
    Object? selectedId = _keepInt,
  }) => PassengersViewState(
    status: status ?? this.status,
    date: date ?? this.date,
    error: error,
    search: identical(search, _keep) ? this.search : search as String?,
    selectedId: identical(selectedId, _keepInt) ? this.selectedId : selectedId as int?,
  );

}

// sentinels for nullable fields in copyWith
const Object _keep = Object();
const Object _keepInt = Object();

class PassengersViewNotifier extends Notifier<PassengersViewState> {
  PassengersViewNotifier(this.date);

  final DateTime date;

  @override
  PassengersViewState build() => PassengersViewState.initial(date);

  // Mutations
  void setLoading() => state = state.copyWith(status: LoadStatus.loading, error: null);

  void setData(List<Passenger> data) => state = state.copyWith(status: LoadStatus.success, passengers: data, error: null);

  void setError(String msg) => state = state.copyWith(status: LoadStatus.error, error: msg);

  void setSearch(String? q) => state = state.copyWith(search: q);

  void setSelected(int? id) => state = state.copyWith(selectedId: id);
}

// Expose ONE provider for the whole view state (family by date) + autoDispose.
final passengersViewStateProvider = NotifierProvider.family<PassengersViewNotifier, PassengersViewState, DateTime>(PassengersViewNotifier.new);
