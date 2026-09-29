import 'dart:async';
import 'package:flutter/material.dart';

/// Session Security Inactivity Watchdog & Token Expiry Manager
class SessionSecurityService {
  static final SessionSecurityService _instance = SessionSecurityService._internal();
  factory SessionSecurityService() => _instance;
  SessionSecurityService._internal();

  Timer? _inactivityTimer;
  Duration _timeoutDuration = const Duration(minutes: 15);
  bool _isLocked = false;
  final bool _enabled = true;
  VoidCallback? _onSessionExpired;

  bool get isLocked => _isLocked;
  Duration get timeoutDuration => _timeoutDuration;

  /// Initialize session watchdog with callback for timeout
  void initialize({
    required VoidCallback onSessionExpired,
    Duration? timeout,
    bool autoStart = false,
  }) {
    _onSessionExpired = onSessionExpired;
    if (timeout != null) _timeoutDuration = timeout;
    if (autoStart && _enabled) {
      resetInactivityTimer();
    }
  }

  /// Update timeout setting (e.g. 5m, 15m, 30m)
  void updateTimeout(Duration newTimeout) {
    _timeoutDuration = newTimeout;
    if (_enabled) resetInactivityTimer();
  }

  /// Reset inactivity timer whenever user touches/interacts with the app
  void recordUserActivity() {
    if (_isLocked || !_enabled) return;
    resetInactivityTimer();
  }

  /// Internal timer reset
  void resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (!_enabled) return;
    _inactivityTimer = Timer(_timeoutDuration, _handleInactivityTimeout);
  }

  void _handleInactivityTimeout() {
    _isLocked = true;
    _onSessionExpired?.call();
  }

  /// Unlock session after re-authentication
  void unlockSession() {
    _isLocked = false;
    resetInactivityTimer();
  }

  /// Invalidate and stop watchdog on logout or disposal
  void disposeWatchdog() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _isLocked = false;
  }
}
