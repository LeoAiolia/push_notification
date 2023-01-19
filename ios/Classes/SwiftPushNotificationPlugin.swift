import Flutter
import UIKit
import UserNotifications


let CALLBACK_OPEN = "notificationOpen"
let CALLBACK_PERMISSION_DECLINE = "permissionDecline"
let CALLBACK_DEVICE_TOKEN = "deviceToken"


@available(iOS 10.0, *)
public class SwiftPushNotificationPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate, UIApplicationDelegate {
    
    var channel :FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "yxr_push_notification", binaryMessenger: registrar.messenger())
        let instance = SwiftPushNotificationPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        // 监听delegate
        registrar.addApplicationDelegate(instance)
        UNUserNotificationCenter.current().delegate = instance
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! NSDictionary
        switch call.method{
        case "request":
            requestPermissions(args: args, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
            return
        }
    }
    
    // Initialize Notifications
    func requestPermissions(args : NSDictionary, result: @escaping FlutterResult) {
        let requestAlertPermission = args["requestAlertPermission"] as! Bool
        let requestSoundPermission = args["requestSoundPermission"] as! Bool
        let requestBadgePermission = args["requestBadgePermission"] as! Bool
        // Notification Options
        var options: UNAuthorizationOptions = []
        
        // Enable notifications if requestAlertPermission == true
        if requestAlertPermission {
            options.insert(.alert)
        }
        // Enable notification sound if requestSoundPermission == true
        if requestSoundPermission {
            options.insert(.sound)
        }

        if requestBadgePermission {
          options.insert(.badge)
        }
        
        // Permission request for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                self.channel.invokeMethod(CALLBACK_PERMISSION_DECLINE, arguments: nil)
                result(didAllow)
                return
            }
             print("notification request is done")
            self.getNotificationSettings()
            result(didAllow)
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else  { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    /*  Called when the application is in the foreground. We get a UNNotification object that contains the UNNotificationRequest request. In the body of the method, you need to make a completion handler call with a set of options to notify UNNotificationPresentationOptions
     */
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    /*  Used to select a tap action for notification. You get a UNNotificationResponse object that contains an actionIdentifier to define an action. The system identifiers UNNotificationDefaultActionIdentifier and UNNotificationDismissActionIdentifier are used when you need to open the application by tap on a notification or close a notification with a swipe.
     */
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        let notificationData = notification.request.content.userInfo

        channel.invokeMethod(CALLBACK_OPEN, arguments: notificationData)
        completionHandler()
    }
    
    // 获取device token
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
          
        debugPrint("--->deviceToken: \(token)")
        channel.invokeMethod(CALLBACK_DEVICE_TOKEN, arguments: token)
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("--->deviceToken error: \(error.localizedDescription)")
    }
}
