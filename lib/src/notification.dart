// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'android/android_notification.dart';
import 'ios/ios_notification.dart';
import 'utils/platform_wrapper.dart';

/// Callback notification clicks.
///
/// [notificationData] - notification data.
typedef OnNotificationTapCallback = void Function(Map notificationData);

/// Callback on permission decline.
typedef OnPermissionDeclineCallback = void Function();

typedef OnDeviceTokenCallback = void Function(String);

const String openCallback = 'notificationOpen';
const String permissionDeclineCallback = 'permissionDecline';
const String deviceTokenCallback = 'deviceToken';

/// Util for displaying notifications for Android and iOS.
class PushNotificationCenter {
  static const channel = MethodChannel('yxr_push_notification');

  /// Callback notification clicks.
  final OnNotificationTapCallback onNotificationTapCallback;

  /// Callback notification decline(iOS only).
  final OnPermissionDeclineCallback? onPermissionDecline;

  final OnDeviceTokenCallback? onDeviceTokenCallback;

  @visibleForTesting
  final PlatformWrapper platform;

  IOSNotification? iosNotification;
  AndroidNotification? androidNotification;

  PushNotificationCenter({
    required this.onNotificationTapCallback,
    this.onPermissionDecline,
    this.iosNotification,
    this.androidNotification,
    PlatformWrapper? platform,
    MethodChannel? channel,
    this.onDeviceTokenCallback,
  }) : platform = platform ?? PlatformWrapper() {
    init(methodChannel: channel);
  }

  /// Request notification permissions (iOS only).
  Future<bool?> requestPermissions({
    bool? requestSoundPermission,
    bool? requestAlertPermission,
    bool? requestBadgePermission,
  }) {
    if (!platform.isIOS) {
      return Future.value(true);
    } else {
      return iosNotification!.requestPermissions(
        requestSoundPermission: requestSoundPermission,
        requestAlertPermission: requestAlertPermission,
        requestBadgePermission: requestBadgePermission,
      );
    }
  }

  @visibleForTesting
  Future init({MethodChannel? methodChannel}) async {
    if (platform.isAndroid) {
      androidNotification ??= AndroidNotification(
        onNotificationTap: onNotificationTapCallback,
      );

      return androidNotification!.init();
    } else if (platform.isIOS) {
      iosNotification ??= IOSNotification(
        onNotificationTap: onNotificationTapCallback,
        onPermissionDecline: onPermissionDecline,
        onDeviceTokenCallback: onDeviceTokenCallback,
      );

      return iosNotification!.init();
    }
  }
}
