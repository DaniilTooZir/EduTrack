import 'package:edu_track/utils/app_result.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';

mixin DataLoadingMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = true;

  Future<void> loadAsync<D>(
    Future<AppResult<D>> fetch, {
    required void Function(D data) onSuccess,
    bool showError = true,
  }) async {
    setState(() => isLoading = true);
    final result = await fetch;
    if (result.isFailure) {
      if (showError) MessengerHelper.showError(result.errorMessage);
      if (mounted) setState(() => isLoading = false);
      return;
    }
    if (mounted) {
      setState(() {
        onSuccess(result.data);
        isLoading = false;
      });
    }
  }
}
