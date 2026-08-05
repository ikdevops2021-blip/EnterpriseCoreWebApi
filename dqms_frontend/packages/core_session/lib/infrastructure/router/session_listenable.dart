import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_status.dart';
import '../../domain/repositories/i_session_repository.dart';

/// Listenable adapter enabling GoRouter.refreshListenable integration.
class SessionListenable extends ChangeNotifier {
  final ISessionRepository _repository;
  late final StreamSubscription<AuthStatus> _subscription;
  AuthStatus _status = AuthStatus.unknown;

  SessionListenable(this._repository) {
    _subscription = _repository.authStatusStream.listen((status) {
      if (_status != status) {
        _status = status;
        notifyListeners();
      }
    });
  }

  AuthStatus get status => _status;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
