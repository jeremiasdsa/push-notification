func userNotificationCenter(_ center: UNUserNotificationCenter, 
                   willPresent notification: UNNotification, 
                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
}

 func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
       // If you need to choose what to do according app state.
        let state: UIApplicationState = application.applicationState
        switch state {
        case .active:
            print("$$$$ ACTIVE")
        case .background:
            print("$$$$ BACGROUND")
        case .inactive:
            print("$$$$ INACTIVE")
        }
        
        // LocalNotifications does not trigger NotificationServiceExtension. But we can add attachment too.
        // They trigger NotificationContentExtension if categoryIdentifier is setted
        let content = UNMutableNotificationContent()
        content.title = userInfo["title"] as! String
        content.body = userInfo["description"] as! String
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "attachmentCategory"
        content.userInfo = userInfo
        
        let id = userInfo["id"] as! String
        let alertType = userInfo["type"] as! String

        let img = NotificationType(rawValue: alertType)!.imageStr
        
        //Adding a custom attachment
        if let path = Bundle.main.path(forResource: img, ofType:"png") {
            let url = URL(fileURLWithPath: path)
            do {
                let attatchment = try UNNotificationAttachment(identifier: "img", url: url, options: [UNNotificationAttachmentOptionsTypeHintKey: kUTTypePNG])
                content.attachments = [attatchment]
                
            } catch {
                print("The attachment was not loaded.")
            }
        }

        //creating a trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
        let request = UNNotificationRequest(identifier: "attachmentCategory", content: content, trigger: trigger)
        
        //Choosing if the local notification should be triggered
        if self.shoudNofity(id: id, alertType:alertType) {
            UNUserNotificationCenter.current().add(request) { (error) in
                if error != nil {
                    print("Error \(error.debugDescription)")
                } else {
                    completionHandler(UIBackgroundFetchResult.newData)
                }
            }
        }
    }
