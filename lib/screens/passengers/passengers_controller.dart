import 'dart:developer';

import 'package:riverpod/riverpod.dart';
import 'package:struct2/core/abstracts/base_result.dart';

import '../../core/abstracts/base_controller.dart';
import '../../core/navigation/routes.dart';
import 'passengers_repository.dart';
import 'passengers_view_state.dart';
import 'usecases/get_passengers_by_date_usecase.dart';

class PassengersController extends BaseController {
  PassengersController({required this.ref, required this.viewState, required this.date});

  final Ref ref; // for listens, if needed
  final PassengersRepository repo = PassengersRepository(); // injected repo
  final PassengersViewNotifier viewState; // injected view-state notifier
  final DateTime date;

  @override
  Future<void> onInit() async {
    logI('onInit · date=$date');
    await load();
  }

  Future<void> load() async {
    try {
      viewState.setLoading();
      final response = await GetPassengersByDateUseCase(repo).call(GetPassengersByDateRequest(date));
      // final GetPassengersByDateUseCase getPassengersByDateUseCase = GetPassengersByDateUseCase(repo);
      // final response = await getPassengersByDateUseCase.call(GetPassengersByDateRequest(date));
      response.onOk((ok) => viewState.setData(ok.passengers));
      response.onErr((err) {
        log("on err on err ${err.message}");
      });
    } catch (e, st) {
      logE('load failed', e, st);
      viewState.setError(e.toString());
      showSnack('Failed to load passengers');
    }
  }

  Future<void> refresh() => load();

  void goToDetails({required String passengerId}) {
    final target = Uri(path: "/passengers/passenger/$passengerId", queryParameters: Routes.qDate(DateTime.now())).toString();
    go(target.toString());
  }

  @override
  Future<void> onDispose() async {
    logI('onDispose');
    await super.onDispose();
  }
}
