//
//  HomeView.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var notificationHandler: NotificationHandler
    @FetchRequest(sortDescriptors: [])
    private var myListResults: FetchedResults<MyList>
    
    @FetchRequest(sortDescriptors: [])
    private var searchResults: FetchedResults<Reminder>
    
    @FetchRequest(sortDescriptors: [])
    private var searchListResults: FetchedResults<MyList>
    
    @FetchRequest(fetchRequest: ReminderService.remindersByStatType(statType: .today))
    private var todayResults: FetchedResults<Reminder>
    
    @FetchRequest(fetchRequest: ReminderService.remindersByStatType(statType: .scheduled))
    private var scheduledResults: FetchedResults<Reminder>
    
    @FetchRequest(fetchRequest: ReminderService.remindersByStatType(statType: .all))
    private var allResults: FetchedResults<Reminder>
    
    @FetchRequest(fetchRequest: ReminderService.remindersByStatType(statType: .completed))
    private var completedResults: FetchedResults<Reminder>
    
    @State private var search: String = ""
    @State private var isPresented: Bool = false
    @State private var searching: Bool = false
    @State private var selectedReminder: Reminder?
    @State private var showReminderDetail: Bool = false
    
    private var reminderStats = ReminderStatsBuilder()
    @State private var reminderStatsValues = ReminderStatsValues()
    
    var body: some View {
        NavigationStack {
            if searching {
                // Search Results View
                List {
                    if !searchListResults.isEmpty {
                        Section("Lists") {
                            ForEach(searchListResults) { list in
                                NavigationLink(value: list) {
                                    MyListCellView(myList: list, showChevron: false)
                                }
                            }
                        }
                    }
                    
                    if !searchResults.isEmpty {
                        Section("Reminders") {
                            ForEach(searchResults) { reminder in
                                ReminderCellView(reminder: reminder, isSelected: false) { event in
                                    switch event {
                                    case .onSelect(let reminder):
                                        selectedReminder = reminder
                                        showReminderDetail = true
                                    case .onCheckChanged(let reminder, let isCompleted):
                                        var editConfig = ReminderEditConfig(reminder: reminder)
                                        editConfig.isCompleted = isCompleted
                                        do {
                                            _ = try ReminderService.updateReminder(reminder: reminder, editConfig: editConfig)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    case .onInfo:
                                        selectedReminder = reminder
                                        showReminderDetail = true
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationDestination(for: MyList.self) { myList in
                    MyListDetailView(myList: myList)
                        .navigationTitle(myList.name)
                }
            } else {
                // Main Content View
                ScrollView {
                    HStack {
                        NavigationLink {
                            ReminderListView(reminders: todayResults)
                        } label: {
                            ReminderStatsView(icon: "calendar", title: "Today", count: reminderStatsValues.todayCount, iconColor: .red)
                        }
                        
                        NavigationLink {
                            ReminderListView(reminders: scheduledResults)
                        } label: {
                            ReminderStatsView(icon: "calendar.badge.exclamationmark", title: "Scheduled", count: reminderStatsValues.scheduledCount, iconColor: .blue)
                        }
                    }
                    
                    HStack {
                        NavigationLink {
                            ReminderListView(reminders: allResults)
                        } label: {
                            ReminderStatsView(icon: "tray.circle.fill", title: "All", count: reminderStatsValues.allCount, iconColor: .orange)
                        }
                        
                        NavigationLink {
                            ReminderListView(reminders: completedResults)
                        } label: {
                            ReminderStatsView(icon: "checkmark.circle.fill", title: "Completed", count: reminderStatsValues.completedCount, iconColor: .green)
                        }
                    }
                    
                    Text("My Lists")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    MyListView(myLists: myListResults)
                    
                    Button {
                        isPresented = true
                    } label: {
                        Text("Add List")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.headline)
                    }.padding()
                }
                .refreshable {
                    // Refresh all fetch requests
                    todayResults.nsPredicate = ReminderService.remindersByStatType(statType: .today).predicate
                    scheduledResults.nsPredicate = ReminderService.remindersByStatType(statType: .scheduled).predicate
                    allResults.nsPredicate = ReminderService.remindersByStatType(statType: .all).predicate
                    completedResults.nsPredicate = ReminderService.remindersByStatType(statType: .completed).predicate
                    reminderStatsValues = reminderStats.build(myListResults: myListResults)
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationView {
                AddNewListView { name, color in
                    do {
                        try ReminderService.saveMyList(name, color)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .onChange(of: search, perform: { searchTerm in
            searching = !searchTerm.isEmpty ? true : false
            searchResults.nsPredicate = ReminderService.getRemindersBySearchTerm(search).predicate
            searchListResults.nsPredicate = ReminderService.getListsBySearchTerm(search).predicate
        })
        .onAppear {
            reminderStatsValues = reminderStats.build(myListResults: myListResults)
        }
        .navigationTitle("Reminders")
        .sheet(isPresented: $showReminderDetail) {
            if let reminder = selectedReminder {
                ReminderDetailView(reminder: .constant(reminder))
            }
        }
        .onChange(of: notificationHandler.shouldNavigateToReminder) { shouldNavigate in
            if shouldNavigate {
                handleNotificationNavigation()
            }
        }
        .searchable(text: $search)
    }
    
    private func handleNotificationNavigation() {
        guard let reminderId = notificationHandler.selectedReminderId else { return }
        
        // Find the reminder in all results
        if let reminder = allResults.first(where: { $0.objectID.uriRepresentation().absoluteString == reminderId }) {
            selectedReminder = reminder
            showReminderDetail = true
        }
        
        // Reset the notification handler state
        notificationHandler.shouldNavigateToReminder = false
        notificationHandler.selectedReminderId = nil
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, CoreDataProvider.shared.persistentContainer.viewContext)
    }
}
