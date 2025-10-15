import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../passengers/passengers_provider.dart';

class PassengerDetailsView extends ConsumerWidget {
  final DateTime date;
  final String passengerId;
  const PassengerDetailsView({super.key, required this.date, required this.passengerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(passengerDetailsProvider((date: date, passengerId: passengerId)));

    return Scaffold(
      appBar: AppBar(title: Text('Passenger $passengerId')),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (f) => Padding(
          padding: const EdgeInsets.all(16),
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
    );
  }
}
