//
//  Swifty_ReminderApp.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationManager.handleNotificationResponse(response)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct Swifty_ReminderApp: App {
    @StateObject private var notificationHandler = NotificationHandler()
    
    init() {
        let delegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = delegate
        
        // Schedule the request with the system.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // request Notificaton
            }
            else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environment(\.managedObjectContext, CoreDataProvider.shared.persistentContainer.viewContext)
                .environmentObject(notificationHandler)
        }
    }
}
