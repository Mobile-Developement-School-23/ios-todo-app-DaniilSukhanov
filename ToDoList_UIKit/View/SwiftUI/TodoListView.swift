//
//  TodoListView.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 15.07.2023.
//

import SwiftUI

struct TodoListView: View {
    @StateObject private var store: SwiftUITodoListStore = .init()
    @State private var selectedTodoItem: TodoItem?
    @State private var isShowingMakeTask = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationStack {
                    List {
                        Section {
                            ForEach(
                                isShowingMakeTask ?
                                store.state.fileCache.items :
                                    store.state.fileCache.items.filter { !$0.isMake }
                            ) { item in
                                TodoCellView(item: item)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTodoItem = item
                                    }
                                
                            }
                            Button {
                                selectedTodoItem = .init(text: "", importance: .usual, isMake: false, createdDate: .now)
                            } label: {
                                Text("Новое")
                                    .foregroundColor(.gray)
                            }
                            
                        } header: {
                            HStack {
                                Text("Выполнено - \(store.state.fileCache.items.filter { $0.isMake }.count)")
                                Spacer()
                                Button {
                                    isShowingMakeTask.toggle()
                                } label: {
                                    (isShowingMakeTask ? Text("Скрыть") : Text("Показать"))
                                    
                                }
                            }
                        }.textCase(nil)
                            .sheet(item: $selectedTodoItem) { item in
                                TodoItemView(todoItem: item)
                            }
                    }.navigationTitle("Мои дела")
                }.environmentObject(store)
                    .onAppear {
                        Task {
                            await store.process(.loadItems)
                        }
                    }
                Button {
                    selectedTodoItem = .init(text: "", importance: .usual, isMake: false, createdDate: .now)
                } label: {
                    Circle()
                        .fill(.blue)
                        .overlay(alignment: .center) {
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 23, height: 23)
                        }
                }
                .frame(width: 44, height: 44)
                    .position(x: 0.5 * geometry.size.width, y: 0.98 * geometry.size.height)
            }
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
