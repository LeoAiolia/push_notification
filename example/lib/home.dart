import 'package:flutter/cupertino.dart';
import 'package:push_notification/push_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PushNotificationCenter pushCenter;

  @override
  void initState() {
    super.initState();

    pushCenter = PushNotificationCenter(onPermissionDecline: () {
      // 通知权限关闭
      // ignore: avoid_print
      print('permission decline');
    }, onNotificationTapCallback: (notificationData) {
      // ignore: avoid_print
      print('notification open: ${notificationData['key'].toString()}');
    }, onDeviceTokenCallback: (deviceToken) {
      // ignore: avoid_print
      print('deviceToken: $deviceToken');
    })
      ..requestPermissions(
        requestSoundPermission: true,
        requestAlertPermission: true,
      ).then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
