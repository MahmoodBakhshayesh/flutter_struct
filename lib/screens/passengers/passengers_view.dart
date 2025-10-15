import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/routes.dart';
import 'passengers_provider.dart';

class PassengersView extends ConsumerWidget {
  final DateTime date;
  const PassengersView({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengersAsync = ref.watch(passengersByDateProvider(date));

    return Scaffold(
      appBar: AppBar(title: Text('Passengers • ${date.toIso8601String().split("T").first}')),
      body: passengersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (passengers) {
          if (passengers.isEmpty) return const Center(child: Text('No passengers'));
          return ListView.separated(
            itemCount: passengers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final f = passengers[i];
              return ListTile(
                title: Text('${f.firstName} → ${f.lastName}'),
                subtitle: Text('ID: ${f.id}'),
                onTap: () => context.push(
                  Uri(
                    path: Routes.passengerDetails,
                    queryParameters: Routes.qPassenger(date, f.id),
                  ).toString(),

                ),
              );
            },
          );
        },
      ),
    );
  }
}
