//
//  ReminderService.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import CoreData
import Foundation
import UIKit

class ReminderService {
    static var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    static func save() throws {
        try viewContext.save()
    }
    
    static func saveMyList(_ name: String, _ color: UIColor) throws {
        let myList = MyList(context: viewContext)
        myList.name = name
        myList.color = color
        try save()
    }
    
    static func deleteMyList(_ myList: MyList) throws {
        viewContext.delete(myList)
        try save()
    }
    
    static func updateReminder(reminder: Reminder, editConfig: ReminderEditConfig) throws -> Bool {
        let reminderToUpdate = reminder
        reminderToUpdate.isCompleted = editConfig.isCompleted
        reminderToUpdate.title = editConfig.title
        reminderToUpdate.notes = editConfig.notes
        reminderToUpdate.reminderDate = editConfig.hasDate ? editConfig.reminderDate : nil
        reminderToUpdate.reminderTime = editConfig.hasTime ? editConfig.reminderTime : nil
        
        try save()
        return true
    }
    
    static func deleteReminder(_ reminder: Reminder) throws {
        viewContext.delete(reminder)
        try save()
    }
    
    static func getRemindersBySearchTerm(_ searchTerm: String) -> NSFetchRequest<Reminder> {
        let request = Reminder.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
        return request
    }
    
    static func getListsBySearchTerm(_ searchTerm: String) -> NSFetchRequest<MyList> {
        let request = MyList.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchTerm)
        return request
    }
    
    static func saveReminderToMyList(myList: MyList, reminderTitle: String) throws {
        let reminder = Reminder(context: viewContext)
        reminder.title = reminderTitle
        myList.addToReminders(reminder)
        try save()
    }
    
    static func remindersByStatType(statType: ReminderStatType) -> NSFetchRequest<Reminder> {
        let request = Reminder.fetchRequest()
        request.sortDescriptors = []
        
        switch statType {
        case .all:
            request.predicate = NSPredicate(format: "isCompleted = false AND list != nil")
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            request.predicate = NSPredicate(format: "((reminderDate >= %@ AND reminderDate < %@) OR (reminderTime != nil AND reminderDate == nil)) AND isCompleted = false AND list != nil", today as NSDate, tomorrow as NSDate)
        case .scheduled:
            request.predicate = NSPredicate(format: "(reminderDate != nil OR reminderTime != nil) AND isCompleted = false AND list != nil")
        case .completed:
            request.predicate = NSPredicate(format: "isCompleted = true AND list != nil")
        }
        
        return request
    }
    
    static func getRemindersByList(myList: MyList) -> NSFetchRequest<Reminder> {
        let request = Reminder.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "list = %@ AND isCompleted = false", myList)
        return request
    }
}
