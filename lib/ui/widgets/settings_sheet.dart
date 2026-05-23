import 'package:edu_track/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showSettingsSheet(BuildContext context) {
  context.push(AppRoutes.settings);
}
