import UIKit
import Flutter
import Firebase

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate {
    
    var currentUserId: String = ""
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        getCurrentUserId()
        GeneratedPluginRegistrant.register(with: self)
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            if let channelInfo = userInfo["channelId"] as? String {
                print(channelInfo)
                self.openChatScreen(conversationId: channelInfo)
            }
            
            if let cardId = userInfo["cardId"] as? Int {
                print(cardId)
                self.openCardDetailsScreen(cardId: cardId)
            }
        }
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            if let channelInfo = userInfo["channelId"] as? String {
                print(channelInfo)
                self.openChatScreen(conversationId: channelInfo)
            }
            
            if let cardId = userInfo["cardId"] as? Int {
                print(cardId)
                self.openCardDetailsScreen(cardId: cardId)
            }
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {
        
        print(response.notification.request.content.userInfo)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Chan
        if let cardId = response.notification.request.content.userInfo["cardId"] as? String {
            print(cardId)
            let intCardId = Int(cardId)!
            self.openCardDetailsScreen(cardId: intCardId)
        } else {
            self.openChatScreen(conversationId: response.notification.request.content.userInfo["channelId"] as! String)
        }
        }
        
   
        return completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let messageAuthor = notification.request.content.userInfo["messageAuthor"] as? String{
            if (currentUserId != messageAuthor){
                 completionHandler([.alert, .badge, .sound])
            } else {
                completionHandler([])
            }
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    func openChatScreen(conversationId: String){
        let rootViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let channel = FlutterBasicMessageChannel(
            name: "iosNotificationTapped",
            binaryMessenger: rootViewController as! FlutterBinaryMessenger,
            codec: FlutterStringCodec.sharedInstance())
        
        channel.sendMessage(conversationId)
        NSLog("OPEN CHAT")
    }
    
    func openCardDetailsScreen(cardId: Int){
        NSLog("OPEN CARD DETAILS")
        let rootViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let channel = FlutterBasicMessageChannel(
            name: "iosRecommendationTapped",
            binaryMessenger: rootViewController as! FlutterBinaryMessenger,
            codec: FlutterStringCodec.sharedInstance())
        
        channel.sendMessage(String(cardId))
    }
    
    func getCurrentUserId(){
        let rootViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let channel = FlutterBasicMessageChannel(
            name: "currentUserId",
            binaryMessenger: rootViewController as! FlutterBinaryMessenger,
            codec: FlutterStringCodec.sharedInstance())
        
        channel.setMessageHandler { (message, flutter) in
            self.currentUserId = message as! String
            NSLog("CURRENT USER LISTENER SET")
        }
    }
}
