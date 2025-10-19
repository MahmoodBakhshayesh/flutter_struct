import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../passengers/passengers_provider.dart';
import 'passenger_details_provider.dart';

class PassengerDetailsView extends ConsumerStatefulWidget {
  final DateTime date;
  final String passengerId;
  const PassengerDetailsView({super.key, required this.date, required this.passengerId});

  @override
  ConsumerState<PassengerDetailsView> createState() => _PassengerDetailsViewState();
}

class _PassengerDetailsViewState extends ConsumerState<PassengerDetailsView> {
  @override
  Widget build(BuildContext context) {
    log("build details");
    final detailsAsync = ref.watch(passengerDetailsProvider((date: widget.date, passengerId: widget.passengerId)));
    // final controller = ref.watch(passengerDetailsControllerProvider(date));
    // log("GoRouter.of(context).state.path ${GoRouter.of(context).state.uri}");
    return Scaffold(
      appBar: AppBar(title: Text('Passenger ${widget.passengerId}')),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (f) => Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: (){
              // controller.pop();
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
