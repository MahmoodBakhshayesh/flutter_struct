import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:struct2/screens/passenger_details/passenger_details_controller.dart';
import 'package:struct2/screens/passenger_details/passenger_details_provider.dart';
import 'package:struct2/screens/passenger_details/passenger_details_view_phone.dart';

class PassengerDetailsView extends ConsumerWidget {
  final DateTime date;
  final String id;
  const PassengerDetailsView({super.key, required this.id, required this.date});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final PassengerDetailsController myPassengersController = ref.watch(passengerDetailsControllerProvider((id,date)));
    return PassengerDetailsViewPhone(myPassengersController, date: date,passengerId: id,);
  }
}