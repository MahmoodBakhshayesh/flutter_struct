import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:struct2/core/abstracts/base_state.dart';
import 'package:struct2/screens/passenger_details/passenger_details_controller.dart';
import 'package:struct2/screens/passenger_details/passenger_details_view_state.dart';
import '../passengers/passengers_provider.dart';
import 'passenger_details_provider.dart';

class PassengerDetailsViewPhone extends ConsumerWidget {
  final DateTime date;
  final String passengerId;
  final PassengerDetailsController myPassengerDetailsController;

  const PassengerDetailsViewPhone(this.myPassengerDetailsController, {super.key, required this.date, required this.passengerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // log("build details");
    final state = ref.watch(passengerDetailsViewStateProvider((passengerId, date)));
    // final detailsAsync = ref.watch(passengerDetailsProvider((date: date, passengerId: passengerId)));
    // final controller = ref.watch(passengerDetailsControllerProvider(date));
    // log("GoRouter.of(context).state.path ${GoRouter.of(context).state.uri}");
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              // ref.invalidate(passengerDetailsViewStateProvider((passengerId,date)),asReload: true);
              myPassengerDetailsController.load();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
        title: Text('Passenger ${passengerId}'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,err) => Center(child: Text('Error: $e')),
        data: (f) => Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {
              myPassengerDetailsController.showBottomSheet(
                Container(
                  width: double.infinity,
                  height: 100,
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text("ok"),
                    ),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${f.firstName} → ${f.lastName}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Date: ${f.birthDate.toIso8601String()}'),
                Text('ID: ${f.id}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
