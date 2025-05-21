//
//  CoreDataProvider.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import CoreData
import Foundation

class CoreDataProvider {
    static let shared = CoreDataProvider()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        // register transformers
        ValueTransformer.setValueTransformer(UIColorTransformer(), forName: NSValueTransformerName("UIColorTransformer"))
        
        persistentContainer = NSPersistentContainer(name: "RemindersModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Error initializing RemindersModel \(error)")
            }
        }
    }
}
