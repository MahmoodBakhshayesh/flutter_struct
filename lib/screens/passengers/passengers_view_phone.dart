import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:struct2/screens/passengers/passengers_controller.dart';

import '../../core/navigation/routes.dart';
import 'passengers_provider.dart';
import 'passengers_view_state.dart';

class PassengersViewPhone extends ConsumerWidget {
  final PassengersController myPassengerController;
  final DateTime date;

  const PassengersViewPhone(this.myPassengerController, {super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengersAsync = ref.watch(passengersByDateProvider(date));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(passengersByDateProvider(date),asReload: true);
            },
            icon: Icon(Icons.refresh),
          ),
        ],
        title: Text('Passengers • ${date.toIso8601String().split("T").first}'),
      ),
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
                onTap: () => myPassengerController.goToDetails(passengerId: f.id),
                // onTap: (){
                //   final target = Uri(path: "/passengers/passenger/${f.id}",
                //       queryParameters: Routes.qDate(DateTime.now())).toString();
                //   context.go(target.toString());
                //   // context.push(target.toString());
                // },
              );
            },
          );
        },
      ),
    );
  }
}
