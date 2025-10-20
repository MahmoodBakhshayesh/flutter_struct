import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart' show CancelToken;
import '../../core/abstracts/base_repository.dart';
import '../../core/classes/passenger_class.dart';

class PassengersRepository extends BaseRepository {
  PassengersRepository();

  /// Always fetch fresh list for a date
  Future<List<Passenger>> fetchByDate(
    DateTime date, {
    CancelToken? cancelToken, // optional: pass if you want external control
  }) async {
    final token = cancelToken ?? CancelToken();
    return await guard<List<Passenger>>(() async {
      final res = await nm.get('/passengers', query: qp({'date': ymd(date)}), cancelToken: token);
      return mapList<Passenger>(res.data, Passenger.fromJson);
    }, op: 'GET /passengers?date=${ymd(date)}');
  }

  /// Always fetch fresh details for a passenger id (+ optional date filter)
  Future<Passenger> fetchById(String id, {required DateTime date, CancelToken? cancelToken}) async {
    final token = cancelToken ?? CancelToken();
    return await withRetry<Passenger>(
      (attempt) async {
        return await guard<Passenger>(() async {
          final res = await nm.get('/passengers/$id', query: qp({'date': ymd(date)}), cancelToken: token);
          return Passenger.fromJson(asJsonMap(res.data));
        }, op: 'GET /passengers/$id (attempt $attempt)');
      },
      maxAttempts: 2,
      op: 'fetchById',
    );
  }

  // No-op helpers preserved for API compatibility (safe to remove if unused)
  void prefetchByDate(DateTime date) {}

  void clearAll() {}
}
