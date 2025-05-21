//
//  NotificationHandler.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import SwiftUI

class NotificationHandler: ObservableObject {
    @Published var selectedReminderId: String?
    @Published var shouldNavigateToReminder = false
    
    init() {
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationTapped),
            name: NSNotification.Name("ReminderNotificationTapped"),
            object: nil
        )
    }
    
    @objc private func handleNotificationTapped(_ notification: Notification) {
        if let reminderId = notification.userInfo?["reminderId"] as? String {
            selectedReminderId = reminderId
            shouldNavigateToReminder = true
        }
    }
}
