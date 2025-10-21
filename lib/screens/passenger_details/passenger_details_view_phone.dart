import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:struct2/screens/passenger_details/passenger_details_controller.dart';
import 'package:struct2/screens/passenger_details/passenger_details_view_state.dart';
import '../passengers/passengers_provider.dart';
import 'passenger_details_provider.dart';

class PassengerDetailsViewPhone extends ConsumerWidget {
  final DateTime date;
  final String passengerId;
  final PassengerDetailsController myPassengerDetailsController;
  const PassengerDetailsViewPhone(this.myPassengerDetailsController,{super.key, required this.date, required this.passengerId});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    // log("build details");
    final state = ref.watch(passengerDetailsViewStateProvider((passengerId,date)));
    // final detailsAsync = ref.watch(passengerDetailsProvider((date: date, passengerId: passengerId)));
    // final controller = ref.watch(passengerDetailsControllerProvider(date));
    // log("GoRouter.of(context).state.path ${GoRouter.of(context).state.uri}");
    return Scaffold(
      appBar: AppBar(title: Text('Passenger ${passengerId}')),
      body: state.passenger == null?SizedBox(): Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: (){
            // controller.pop();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${state.passenger!.firstName} → ${state.passenger!.lastName}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Date: ${state.passenger!.birthDate.toIso8601String()}'),
              Text('ID: ${state.passenger!.id}'),
            ],
          ),
        ),
      ),
      // body: state..when(
      //   loading: () => const Center(child: CircularProgressIndicator()),
      //   error: (e, st) => Center(child: Text('Error: $e')),
      //   data: (f) => Padding(
      //     padding: const EdgeInsets.all(16),
      //     child: GestureDetector(
      //       onTap: (){
      //         // controller.pop();
      //       },
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text('${f.firstName} → ${f.lastName}', style: Theme.of(context).textTheme.headlineSmall),
      //           const SizedBox(height: 8),
      //           Text('Date: ${f.birthDate.toIso8601String()}'),
      //           Text('ID: ${f.id}'),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
