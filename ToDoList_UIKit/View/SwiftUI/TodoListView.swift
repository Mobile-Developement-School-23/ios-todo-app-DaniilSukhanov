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
    @Environment(\.colorScheme) var colorScheme
    
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
                            }.listRowBackground(
                                colorScheme == .dark ?
                                    Color(red: 0.14, green: 0.14, blue: 0.16) :
                                    .white
                            )
                            Button {
                                selectedTodoItem = .init(text: "", importance: .usual, isMake: false, createdDate: .now)
                            } label: {
                                Text("Новое")
                                    .foregroundColor(.gray)
                            }.listRowBackground(
                                colorScheme == .dark ?
                                    Color(red: 0.14, green: 0.14, blue: 0.16) :
                                    .white
                            )
                            
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
                }.frame(width: 44, height: 44)
                    .position(x: 0.5 * geometry.size.width, y: geometry.size.height - (geometry.size.height * 0.065625))
                    .shadow(
                        color:
                            colorScheme == .light ?
                            Color(red: 0, green: 0.19, blue: 0.4).opacity(0.3) :
                            Color(red: 0, green: 0.29, blue: 0.6).opacity(0.6),
                        radius: 10,
                        x: 0, y: 8
                    )
            }
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
