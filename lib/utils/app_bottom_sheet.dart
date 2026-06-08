import 'package:flutter/material.dart';

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool transparentBackground = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape:
        transparentBackground
            ? null
            : const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    backgroundColor: transparentBackground ? Colors.transparent : null,
    builder: builder,
  );
}
