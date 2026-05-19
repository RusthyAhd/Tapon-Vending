import 'package:flutter/material.dart';

import 'connectivity_service.dart';

class ConnectivityGuard extends StatefulWidget {
  final Widget child;

  const ConnectivityGuard({super.key, required this.child});

  @override
  State<ConnectivityGuard> createState() => _ConnectivityGuardState();
}

class _ConnectivityGuardState extends State<ConnectivityGuard> {
  final ConnectivityService _service = ConnectivityService.instance;
  late ConnectivityStatus _lastStatus;

  @override
  void initState() {
    super.initState();
    _lastStatus = _service.status.value;
    _service.status.addListener(_handleStatusChange);
  }

  @override
  void dispose() {
    _service.status.removeListener(_handleStatusChange);
    super.dispose();
  }

  void _handleStatusChange() {
    final status = _service.status.value;
    if (status == ConnectivityStatus.online &&
        _lastStatus != ConnectivityStatus.online) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Back online. Connection restored.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    setState(() {
      _lastStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConnectivityStatus>(
      valueListenable: _service.status,
      builder: (context, status, _) {
        final blocked = status != ConnectivityStatus.online;

        return Stack(
          children: [
            WillPopScope(
              onWillPop: () async => !blocked,
              child: AbsorbPointer(
                absorbing: blocked,
                child: widget.child,
              ),
            ),
            if (blocked) _ConnectivityPopup(status: status),
          ],
        );
      },
    );
  }
}

class _ConnectivityPopup extends StatelessWidget {
  final ConnectivityStatus status;

  const _ConnectivityPopup({required this.status});

  String get _title {
    switch (status) {
      case ConnectivityStatus.weak:
        return 'Unstable Connection';
      case ConnectivityStatus.offline:
        return 'No Internet Connection';
      case ConnectivityStatus.online:
        return 'Online';
    }
  }

  String get _message {
    switch (status) {
      case ConnectivityStatus.weak:
        return 'Your network is unstable. Some actions are paused.';
      case ConnectivityStatus.offline:
        return 'You are offline. Please reconnect to continue.';
      case ConnectivityStatus.online:
        return 'Connection restored.';
    }
  }

  Color get _indicatorColor {
    switch (status) {
      case ConnectivityStatus.weak:
        return Colors.orangeAccent;
      case ConnectivityStatus.offline:
        return Colors.redAccent;
      case ConnectivityStatus.online:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityService.instance;
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.65),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Material(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _indicatorColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.name.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _indicatorColor,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: service.isChecking,
                          builder: (context, checking, _) {
                            return OutlinedButton(
                              onPressed: checking ? null : service.refresh,
                              child: checking
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Check Again',style: TextStyle(color: Color.fromRGBO(5, 248, 175, 1),),),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: service.refresh,
                          child: const Text('Retry',style: TextStyle(color: Color.fromRGBO(5, 248, 175, 1),),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
