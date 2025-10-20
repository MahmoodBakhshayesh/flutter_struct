// lib/core/usecase/usecase.dart
import 'base_result.dart';

/// Request objects implement `validate()` if needed.
abstract class Request {
  /// Return a Failure to stop the use case, or null if valid.
  Failure? validate();
}

/// Optional response marker (handy for typing/mapping).
abstract class UseCaseResponse {
  const UseCaseResponse();
}

abstract class UseCase<Out extends Object, In extends Request> {
  const UseCase();

  /// Template method: validates first, then runs `exec`.
  Future<Result<Out>> call(In request) async {
    final v = request.validate();
    if (v != null) return Err(v);
    try {
      final out = await exec(request);
      return Ok(out);
    } catch (e, st) {
      // If your repo already throws typed exceptions, map them here if needed.
      return Err(UnknownFailure(e.toString(), cause: e, stackTrace: st));
    }
  }

  Future<Out> exec(In request);
}
