//
//  MyList+CoreDataClass.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import CoreData
import Foundation

@objc(MyList)
public class MyList: NSManagedObject {
    var remindersArray: [Reminder] {
        reminders?.allObjects.compactMap { ($0 as! Reminder) } ?? []
    }
}
