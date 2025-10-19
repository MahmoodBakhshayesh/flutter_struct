import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/abstracts/base_state.dart';
import '../../core/classes/passenger_class.dart';

class PassengersViewState extends ViewState {
  final LoadStatus status;
  final DateTime date;
  final List<Passenger> passengers;
  final String? error;

  const PassengersViewState({required this.status, required this.date, required this.passengers, this.error});

  factory PassengersViewState.initial(DateTime date) => PassengersViewState(status: LoadStatus.idle, date: date, passengers: const []);

  PassengersViewState copyWith({LoadStatus? status, DateTime? date, List<Passenger>? passengers, String? error}) =>
      PassengersViewState(status: status ?? this.status, date: date ?? this.date, passengers: passengers ?? this.passengers, error: error);
}

/// Riverpod 3 style: pass the family arg (date) via the constructor.
class PassengersListNotifier extends Notifier<PassengersViewState> {
  PassengersListNotifier(this.date);

  final DateTime date;

  @override
  PassengersViewState build() => PassengersViewState.initial(date);

  void setLoading() => state = state.copyWith(status: LoadStatus.loading, error: null);

  void setData(List<Passenger> data) => state = state.copyWith(status: LoadStatus.success, passengers: data, error: null);

  void setError(String msg) => state = state.copyWith(status: LoadStatus.error, error: msg);
}

/// Expose STATE to the view (with autoDispose).
final passengersListStateProvider = NotifierProvider.family.autoDispose<PassengersListNotifier, PassengersViewState, DateTime>(PassengersListNotifier.new);
