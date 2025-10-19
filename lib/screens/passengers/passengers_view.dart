import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/routes.dart';
import 'passengers_provider.dart';
import 'passengers_view_state.dart';

class PassengersView extends ConsumerStatefulWidget {
  final DateTime date;

  const PassengersView({super.key, required this.date});

  @override
  ConsumerState<PassengersView> createState() => _PassengersViewState();
}

class _PassengersViewState extends ConsumerState<PassengersView> {
  @override
  Widget build(BuildContext context) {
    log("build list");

    final state = ref.watch(passengersListStateProvider(widget.date));
    final ctrl = ref.watch(passengersListControllerProvider(widget.date));

    final passengersAsync = ref.watch(passengersByDateProvider(widget.date));
    // log("GoRouter.of(context).state.path ${GoRouter.of(context).state.uri}");

    return Scaffold(
      appBar: AppBar(title: Text('Passengers • ${widget.date.toIso8601String().split("T").first}')),
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
                // onTap: () => ctrl.goToDetails(passengerId: f.id),
                onTap: (){
                  final target = Uri(path: "/passengers/passenger/${f.id}",
                      queryParameters: Routes.qDate(DateTime.now())).toString();
                  context.go(target.toString());
                  // context.push(target.toString());
                },
              );
            },
          );
        },
      ),
    );
  }
}
