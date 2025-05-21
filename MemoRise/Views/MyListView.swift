//
//  MyListView.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import SwiftUI

struct MyListView: View {
    let myLists: FetchedResults<MyList>
    @Environment(\.colorScheme) var colorScheme
    @State private var listToDelete: MyList?
    @State private var showDeleteAlert = false
    
    private func deleteMyList(_ myList: MyList) {
        do {
            try ReminderService.deleteMyList(myList)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        NavigationStack {
            if myLists.isEmpty {
                Spacer()
                Text("No reminders found")
            } else {
                ForEach(myLists) { myList in
                    NavigationLink(value: myList) {
                        HStack {
                            VStack {
                                MyListCellView(myList: myList)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading], 10)
                                    .font(.title3)
                                    .foregroundColor(colorScheme == .dark ? Color.offWhite : Color.darkGray)
                                Divider()
                            }
                            
                            Button(action: {
                                listToDelete = myList
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .padding(.trailing, 10)
                        }
                    }
                    .listRowBackground(colorScheme == .dark ? Color.darkGray : Color.offWhite)
                }
                .scrollContentBackground(.hidden)
                .navigationDestination(for: MyList.self) { myList in
                    MyListDetailView(myList: myList)
                        .navigationTitle(myList.name)
                }
                .alert("Delete List", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        if let list = listToDelete {
                            deleteMyList(list)
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete this list? This action cannot be undone.")
                }
            }
        }
    }
}

