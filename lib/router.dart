import 'package:flutter/material.dart';

import 'error.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    default:
      return MaterialPageRoute(
        builder: (_) => const ErrorScreen(
          error: 'Uh-oh! Looks like you are lost in space!',
        ),
      );
  }
}
