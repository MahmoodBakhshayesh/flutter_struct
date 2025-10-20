import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:struct2/screens/passengers/passengers_controller.dart';
import 'package:struct2/screens/passengers/passengers_view_phone.dart';

import '../../core/navigation/routes.dart';
import 'passengers_provider.dart';
import 'passengers_view_state.dart';

class PassengersView extends ConsumerWidget {
  final DateTime date;

  const PassengersView({super.key, required this.date});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
      final PassengersController myPassengersController = ref.watch(passengersListControllerProvider(date));
      return PassengersViewPhone(myPassengersController, date: date);
  }
}
