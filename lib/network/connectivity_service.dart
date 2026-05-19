import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus {
  online,
  weak,
  offline,
}

class ConnectivityGuardException implements Exception {
  final String message;

  ConnectivityGuardException(this.message);

  @override
  String toString() => message;
}

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<ConnectivityStatus> status =
      ValueNotifier(ConnectivityStatus.online);
  final ValueNotifier<bool> isChecking = ValueNotifier(false);

  Timer? _probeTimer;
  bool _started = false;

  bool get hasInternet => status.value == ConnectivityStatus.online;
  bool get isBlocked => status.value != ConnectivityStatus.online;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final initial = await _connectivity.checkConnectivity();
    await _updateFromConnectivity(_normalizeResults(initial));

    _connectivity.onConnectivityChanged.listen((event) {
      _updateFromConnectivity(_normalizeResults(event));
    });

    _probeTimer = Timer.periodic(
      const Duration(seconds: 6),
      (_) => refresh(),
    );

    unawaited(refresh());
  }

  Future<void> dispose() async {
    _probeTimer?.cancel();
  }

  Future<void> refresh() async {
    if (isChecking.value) return;
    isChecking.value = true;

    final probe = await _probeInternet();
    isChecking.value = false;

    _setStatus(probe);
  }

  Future<void> waitForInternet({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (hasInternet) return;

    final completer = Completer<void>();
    late VoidCallback listener;
    listener = () {
      if (hasInternet && !completer.isCompleted) {
        status.removeListener(listener);
        completer.complete();
      }
    };

    status.addListener(listener);

    await completer.future.timeout(
      timeout,
      onTimeout: () {
        status.removeListener(listener);
        throw ConnectivityGuardException('Internet connection not restored.');
      },
    );
  }

  Future<void> _updateFromConnectivity(
    List<ConnectivityResult> results,
  ) async {
    if (results.contains(ConnectivityResult.none)) {
      _setStatus(ConnectivityStatus.offline);
      return;
    }

    await refresh();
  }

  List<ConnectivityResult> _normalizeResults(dynamic results) {
    if (results is List<ConnectivityResult>) {
      return results;
    }

    return <ConnectivityResult>[results as ConnectivityResult];
  }

  Future<ConnectivityStatus> _probeInternet() async {
    if (kIsWeb) {
      return ConnectivityStatus.online;
    }

    final watch = Stopwatch()..start();

    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));

      if (result.isEmpty) {
        return ConnectivityStatus.offline;
      }

      watch.stop();
      final latencyMs = watch.elapsedMilliseconds;

      if (latencyMs > 1800) {
        return ConnectivityStatus.weak;
      }

      return ConnectivityStatus.online;
    } catch (_) {
      return ConnectivityStatus.offline;
    }
  }

  void _setStatus(ConnectivityStatus next) {
    if (status.value == next) return;
    status.value = next;
  }
}

class ConnectivityActionGuard {
  ConnectivityActionGuard._();

  static final ConnectivityActionGuard instance = ConnectivityActionGuard._();

  final Map<String, int> _locks = {};

  bool isLocked(String key) => _locks.containsKey(key);

  Future<T> run<T>(
    String key,
    Future<T> Function() action, {
    bool requireInternet = true,
  }) async {
    if (requireInternet && !ConnectivityService.instance.hasInternet) {
      throw ConnectivityGuardException('No internet connection.');
    }

    if (_locks.containsKey(key)) {
      throw ConnectivityGuardException('Action already in progress.');
    }

    _locks[key] = DateTime.now().millisecondsSinceEpoch;

    try {
      return await action();
    } finally {
      _locks.remove(key);
    }
  }
}

class FirestoreOperationGuard {
  FirestoreOperationGuard._();

  static final FirestoreOperationGuard instance = FirestoreOperationGuard._();

  final Map<String, Object> _inFlight = {};

  Future<T> runWrite<T>(String key, Future<T> Function() write) async {
    return ConnectivityActionGuard.instance.run(
      'firestore:$key',
      () async {
        final token = Object();
        _inFlight[key] = token;

        try {
          if (!ConnectivityService.instance.hasInternet) {
            throw ConnectivityGuardException('No internet connection.');
          }

          final result = await write();

          if (!ConnectivityService.instance.hasInternet) {
            throw ConnectivityGuardException('Connection lost. Try again.');
          }

          return result;
        } finally {
          if (_inFlight[key] == token) {
            _inFlight.remove(key);
          }
        }
      },
    );
  }
}
