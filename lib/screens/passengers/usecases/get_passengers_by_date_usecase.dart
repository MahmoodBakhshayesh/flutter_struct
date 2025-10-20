// features/passengers/usecases/get_passengers_by_date.dart

import '../../../core/abstracts/base_result.dart';
import '../../../core/abstracts/base_usecase.dart';
import '../../../core/classes/passenger_class.dart';
import '../passengers_repository.dart';

class GetPassengersByDateRequest implements Request {
  final DateTime date;
  const GetPassengersByDateRequest(this.date);
  @override Failure? validate() => null; // add rules if needed
}

class GetPassengersByDateResponse {
  final DateTime date;
  final List<Passenger> passengers;
  const GetPassengersByDateResponse({required this.date, required this.passengers});
}

class GetPassengersByDateUseCase extends UseCase<GetPassengersByDateResponse, GetPassengersByDateRequest> {
  final PassengersRepository repo;
  GetPassengersByDateUseCase(this.repo);

  @override
  Future<GetPassengersByDateResponse> exec(GetPassengersByDateRequest req) async {
    final list = await repo.fetchByDate(req.date);
    return GetPassengersByDateResponse(date: req.date, passengers: list);
  }
}