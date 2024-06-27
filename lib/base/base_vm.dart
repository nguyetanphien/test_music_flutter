import 'package:flutter/cupertino.dart';

abstract class BaseViewModel extends ChangeNotifier {
  bool _isFirst = true;
  bool _showLoading = false;
  late VoidCallback onShowLoading, onHideLoading;
  late void Function(String) onShowError;

  BaseViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onInit();
    });
  }

  @protected
  void onInit();

  void showLoading() {
    if (!_showLoading) {
      _showLoading = true;
      onShowLoading.call();
    }
  }

  void hideLoading() {
    if (_showLoading) {
      _showLoading = false;
      onHideLoading.call();
    }
  }

  void showError(String message) {
    hideLoading();
    onShowError.call(message);
  }

  void appear() {
    if (_isFirst) {
      _isFirst = false;
      return;
    }

    try {
      onAppear.call();
    } catch (_) {}
  }

  external void onAppear();

  void disAppear() {
    if (_isFirst) return;

    try {
      onDisAppear();
    } catch (_) {}
  }

  external void onDisAppear();
}
