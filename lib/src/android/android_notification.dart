import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../notification.dart';

const String callInit = 'initialize';

class AndroidNotification {
  final MethodChannel channel = PushNotificationCenter.channel;

  final OnNotificationTapCallback onNotificationTap;
  final OnDeviceTokenCallback? onDeviceTokenCallback;

  AndroidNotification({
    required this.onNotificationTap,
    this.onDeviceTokenCallback,
  });

  Future init() async {
    channel.setMethodCallHandler(
      methodCallHandlerCallback,
    );
    return channel.invokeMethod<dynamic>(callInit);
  }

  @visibleForTesting
  Future<dynamic> methodCallHandlerCallback(MethodCall call) async {
    switch (call.method) {
      case openCallback:
        final notificationData = call.arguments as Map;
        onNotificationTap(notificationData);
        break;
    }
  }
}
