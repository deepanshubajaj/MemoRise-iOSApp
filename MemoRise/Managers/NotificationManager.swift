//
//  NotificationManager.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import Foundation
import UserNotifications

struct UserData {
    let title: String?
    let body: String?
    let time: Date?
    let date: Date?
    let reminderId: String?
}

enum NotificationManager {
    static func scheduleNotification(userData: UserData) {
        let content = UNMutableNotificationContent()
        content.title = userData.title ?? ""
        content.body = userData.body ?? ""
        content.sound = UNNotificationSound(named: UNNotificationSoundName("NotificationSound.mp3"))
        
        // Add reminder ID to the notification payload
        if let reminderId = userData.reminderId {
            content.userInfo = ["reminderId": reminderId]
        }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: userData.date ?? Date())
        
        if let reminderTime = userData.time {
            let reminderDateTimeComponents = reminderTime.dateComponents
            dateComponents.hour = reminderDateTimeComponents.hour
            dateComponents.minute = reminderDateTimeComponents.minute
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        
        let uuidString = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                // Handle any errors.
            }
            else {
                print("Reminder Added")
            }
        }
    }
    
    static func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        if let reminderId = userInfo["reminderId"] as? String {
            // Post notification to handle navigation
            NotificationCenter.default.post(
                name: NSNotification.Name("ReminderNotificationTapped"),
                object: nil,
                userInfo: ["reminderId": reminderId]
            )
        }
    }
}
