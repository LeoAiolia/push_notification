import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../notification.dart';

class IOSNotification {
  final MethodChannel channel = PushNotificationCenter.channel;

  /// Callback notification push.
  final OnNotificationTapCallback onNotificationTap;

  /// Callback on notification decline.
  final OnPermissionDeclineCallback? onPermissionDecline;

  final OnDeviceTokenCallback? onDeviceTokenCallback;

  IOSNotification({
    required this.onNotificationTap,
    this.onPermissionDecline,
    this.onDeviceTokenCallback,
  });

  /// Initialize notification.
  ///
  /// Initializes notification parameters.
  Future init() async {
    channel.setMethodCallHandler(
      methodCallHandlerCallback,
    );
  }

  /// Request permissions.
  ///
  /// [requestSoundPermission] - is play sound.
  /// [requestAlertPermission] - is show alert.
  Future<bool?> requestPermissions({
    bool? requestSoundPermission,
    bool? requestAlertPermission,
    bool? requestBadgePermission,
  }) =>
      channel.invokeMethod<bool>(
        'request',
        {
          'requestAlertPermission': requestAlertPermission ?? false,
          'requestSoundPermission': requestSoundPermission ?? false,
          'requestBadgePermission': requestBadgePermission ?? false,
        },
      );

  @visibleForTesting
  Future<dynamic> methodCallHandlerCallback(MethodCall call) async {
    switch (call.method) {
      case openCallback:
        onNotificationTap(call.arguments as Map);
        break;
      case permissionDeclineCallback:
        if (onPermissionDecline != null) {
          onPermissionDecline!();
        }
        break;
      case deviceTokenCallback:
        onDeviceTokenCallback?.call(call.arguments as String);
        break;
    }
  }
}
