import 'package:flutter/material.dart';

showSnakeBar({required BuildContext ctx, required String text, required Color color}) {
  return ScaffoldMessenger.of(ctx)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: color,
    ));
}
