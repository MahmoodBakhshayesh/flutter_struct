// features/passengers/usecases/get_passengers_by_date.dart

import 'package:struct2/screens/passenger_details/passenger_details_repository.dart';

import '../../../core/abstracts/base_result.dart';
import '../../../core/abstracts/base_usecase.dart';
import '../../../core/classes/passenger_class.dart';

class GetPassengerDetailsByIDRequest implements Request {
  final DateTime date;
  final String id;

  const GetPassengerDetailsByIDRequest({required this.id, required this.date});

  @override
  Failure? validate() => null; // add rules if needed
}

class GetPassengersByDateResponse {
  final DateTime date;
  final Passenger passenger;

  const GetPassengersByDateResponse({required this.date, required this.passenger});
}

class GetPassengerDetailsByIdUseCase extends UseCase<GetPassengersByDateResponse, GetPassengerDetailsByIDRequest> {
  final PassengerDetailsRepository repo;

  GetPassengerDetailsByIdUseCase(this.repo);

  @override
  Future<GetPassengersByDateResponse> exec(GetPassengerDetailsByIDRequest req) async {
    final list = await repo.fetchById(req.id, date: req.date);
    return GetPassengersByDateResponse(date: req.date, passenger: list);
  }
}
