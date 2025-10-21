import 'package:flutter/material.dart';

/// Immutable base state interface (optional – for consistency).
abstract class ViewState {
  const ViewState();
}

/// Generic simple status wrapper you can reuse if you like.
enum LoadStatus { idle, loading, success, error }

extension ViewStateWhenX<T> on dynamic {
  /// Pattern-matching helper similar to `AsyncValue.when()`.
  ///
  /// - [loading]: builder called when `status == LoadStatus.loading`
  /// - [error]: builder called when `status == LoadStatus.error`
  /// - [data]: builder called when `status == LoadStatus.success`
  /// - [idle]: optional builder for initial/idle state
  ///
  /// Example:
  /// ```dart
  /// state.when(
  ///   loading: () => const CircularProgressIndicator(),
  ///   error: (msg) => Text(msg ?? 'Error'),
  ///   data: (passenger) => PassengerCard(passenger),
  /// );
  /// ```
  Widget when({
    required Widget Function() loading,
    required Widget Function(String? message,dynamic err) error,
    required Widget Function(dynamic data) data,
    Widget Function()? idle,
  }) {
    if (this == null) return const SizedBox.shrink();
    final s = this;

    if (s.status == LoadStatus.loading) return loading();
    if (s.status == LoadStatus.error) return error(s.error?.toString(),s);
    if (s.status == LoadStatus.success) return data(s.passenger ?? s.data);
    if (s.status == LoadStatus.idle && idle != null) return idle();

    // fallback
    return const SizedBox.shrink();
  }
}
