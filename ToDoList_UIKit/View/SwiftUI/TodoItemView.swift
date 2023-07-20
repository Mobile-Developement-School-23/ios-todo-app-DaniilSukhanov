//
//  TodoItemView.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 15.07.2023.
//

import SwiftUI

struct TodoItemView: View {
    private enum Focus: Int {
        case textEditor
        
    }
    @EnvironmentObject var store: SwiftUITodoListStore
    @State private var text = ""
    @State private var orientation: UIInterfaceOrientation = .unknown
    @FocusState private var focus: Focus?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var selectedImportance: TodoItem.Importance = .usual
    @State private var isShowingCalendar = false
    @State private var isSelectedDeadline = false
    @State private var selectedDate: Date = .now
    private var currentTodoItem: TodoItem?
    
    init(todoItem: TodoItem? = nil) {
        currentTodoItem = todoItem
    }
    
    private func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        TextEditorResizingView(string: $text, orientation: $orientation,
                                               minHeightPortrait: 120, minHeightLandscape: proxy.size.height - 32)
                        .scrollContentBackground(.hidden)
                        .scrollDisabled(true)
                        .background(
                            colorScheme == .dark ?
                                Color(red: 0.14, green: 0.14, blue: 0.16) :
                                .white
                        )
                        .cornerRadius(16)
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("Что надо сделать?")
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                    .padding(.top, 12)
                                    .font(Font.custom("SF Pro Text", size: 17))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
                            }
                        }
                        .focused($focus, equals: .textEditor)
                        .onTapGesture {
                            focus = .textEditor
                        }
                        if orientation.isPortrait {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Важность")
                                    Spacer(minLength: 16)
                                    Picker("", selection: $selectedImportance) {
                                        Image(systemName: "arrow.down")
                                            .foregroundStyle(.gray, .gray, .gray)
                                            .tag(TodoItem.Importance.unimportant)
                                        Text("Нет")
                                            .tag(TodoItem.Importance.usual)
                                        Image(systemName: "exclamationmark.2")
                                            .foregroundStyle(.red, .red, .red)
                                            .tag(TodoItem.Importance.important)
                                    }.pickerStyle(.segmented)
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                    Toggle("Сделать до", isOn: $isSelectedDeadline)
                                        .onTapGesture {
                                            withAnimation {
                                                isShowingCalendar = !isSelectedDeadline
                                            }
                                        }
                                    if isSelectedDeadline {
                                        Button {
                                            withAnimation {
                                                isShowingCalendar.toggle()
                                            }
                                        } label: {
                                            Text(formateDate(selectedDate))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                if isShowingCalendar {
                                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                                        .datePickerStyle(.graphical)
                                    
                                }
                            }.padding()
                                .background(
                                    colorScheme == .dark ?
                                        Color(red: 0.14, green: 0.14, blue: 0.16) :
                                        .white
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                            Button("Удалить") {
                                Task {
                                    guard let currentTodoItem else {
                                        return
                                    }
                                    await store.process(.removeItem(currentTodoItem.id))
                                }
                                dismiss()
                            }.padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: 18))
                                .foregroundColor(
                                    text.isEmpty ?
                                        (colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3)) :
                                        .red
                                )
                                .disabled(text.isEmpty)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.background, lineWidth: 2)
                                )
                                .background(
                                    colorScheme == .dark ?
                                        Color(red: 0.14, green: 0.14, blue: 0.16) :
                                        .white
                                )
                                .cornerRadius(16)
                            Spacer()
                        }
                    }
                }
                    .padding(16)
                    .background(
                        colorScheme == .light ?
                        Color(red: 0.97, green: 0.97, blue: 0.95) : Color(red: 0.09, green: 0.09, blue: 0.09)
                    )
                    .onAppear {
                        let scenes = UIApplication.shared.connectedScenes
                        let windowScene = scenes.first as? UIWindowScene
                        guard let windowScene else {
                            return
                        }
                        orientation = windowScene.interfaceOrientation
                        guard let currentTodoItem else {
                            return
                        }
                        text = currentTodoItem.text
                        selectedImportance = currentTodoItem.importance
                        if let deadline = currentTodoItem.deadline {
                            selectedDate = deadline
                            isSelectedDeadline = true
                        }
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                    ) { _ in
                        let scenes = UIApplication.shared.connectedScenes
                        let windowScene = scenes.first as? UIWindowScene
                        guard let windowScene else {
                            return
                        }
                        withAnimation {
                            orientation = windowScene.interfaceOrientation
                        }
                    }
                    .onTapGesture {
                        self.focus = nil
                    }.toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Отмена") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Сохранить") {
                                Task {
                                    var newTodoItem: TodoItem
                                    if let todoItem = currentTodoItem {
                                        newTodoItem = .init(
                                            text: text,
                                            importance: selectedImportance,
                                            isMake: todoItem.isMake,
                                            createdDate: todoItem.createdDate,
                                            deadline: isSelectedDeadline ? selectedDate : nil,
                                            changedDate: .now,
                                            id: todoItem.id
                                        )
                                    } else {
                                        newTodoItem = .init(
                                            text: text,
                                            importance: selectedImportance,
                                            isMake: false,
                                            deadline: selectedDate,
                                            changedDate: .now
                                        )
                                    }
                                    await store.process(.addItem(newTodoItem))
                                }
                                dismiss()
                            }.foregroundColor(
                                text.isEmpty ?
                                    (colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3)) :
                                    .blue
                            )
                                .disabled(text.isEmpty)
                        }
                    }
                    .navigationTitle("Дело")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct TodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemView()
    }
}
