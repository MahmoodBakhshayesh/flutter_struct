// lib/core/result/result.dart
sealed class Result<T> {
  const Result();
  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
  T get require => (this as Ok<T>).value;
  Failure get error => (this as Err<T>).error;

  R fold<R>({required R Function(T) ok, required R Function(Failure) err}) =>
      switch (this) { Ok<T>(:final value) => ok(value), Err<T>(:final error) => err(error) };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final Failure error;
  @override
  String toString() => 'Err($error)';
}

// lib/core/result/failure.dart
abstract class Failure {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.cause, this.stackTrace});
  @override
  String toString() => '$runtimeType($message)';
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode, super.cause, super.stackTrace});
}

class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic body;
  const ServerFailure(super.message, {this.statusCode, this.body, super.cause, super.stackTrace});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause, super.stackTrace});
}

extension ResultX<T> on Result<T> {
  void onOk(void Function(T) f) { if (this is Ok<T>) f((this as Ok<T>).value); }
  void onErr(void Function(Failure) f) { if (this is Err<T>) f((this as Err<T>).error); }

  T? okOrNull() => this is Ok<T> ? (this as Ok<T>).value : null;
  Failure? errorOrNull() => this is Err<T> ? (this as Err<T>).error : null;
}
