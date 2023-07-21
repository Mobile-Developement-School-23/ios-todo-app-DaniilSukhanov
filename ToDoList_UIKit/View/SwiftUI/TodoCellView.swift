//
//  TodoCellView.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 18.07.2023.
//

import SwiftUI

struct TodoCellView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: SwiftUITodoListStore
    private let item: TodoItem
    
    init(item: TodoItem) {
        self.item = item
    }
    
    private func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: date)
    }
    
    @ViewBuilder var indicator: some View {
        ZStack {
            if item.isMake {
                Circle()
                    .fill(.green)
                    .overlay(alignment: .center) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 13).bold())
                    }
            } else if item.importance == .important {
                Circle()
                    .strokeBorder(Color.red,lineWidth: 2)
                    .background(Circle().foregroundColor(
                            colorScheme == .light ?
                                Color(red: 1, green: 232/255, blue: 231/255) :
                                Color(red: 52/255, green: 36/255, blue: 38/255)
                        )
                    )
            } else {
                Circle()
                    .strokeBorder(.gray ,lineWidth: 2)
                    .background(Circle().foregroundColor(.clear))
            }
        }.frame(width: 24, height: 24)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            indicator
            if item.importance == .important {
                Image(systemName: "exclamationmark.2")
                    .foregroundColor(.red)
                    .padding(.leading, 12)
            } else if item.importance == .unimportant {
                Image(systemName: "arrow.down")
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
            }
            VStack(alignment: .leading, spacing: 0) {
                let text = Text(item.text)
                    .lineLimit(3)
                    .padding(.leading, [.important, .unimportant].contains(item.importance) ? 0 : 12)
                if item.isMake {
                    text
                        .strikethrough(color: .gray)
                        .foregroundColor(.gray)
                } else {
                    text
                }
                if let deadline = item.deadline {
                    HStack(spacing: 0) {
                        Image(systemName: "calendar")
                        Text(formateDate(deadline))
                    }.foregroundColor(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }.swipeActions(edge: .leading) {
            Button {
                Task {
                    await store.process(.addItem(item.modifier(isMake: true)))
                    await store.process(.saveItems)
                }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            }.tint(.green)
        }.swipeActions(edge: .trailing) {
            Button {
                Task {
                    await store.process(.removeItem(item.id))
                    await store.process(.saveItems)
                }
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
            }.tint(.red)
        }
            
    }
}

struct TodoCellView_Previews: PreviewProvider {
    static var previews: some View {
        TodoCellView(item: .init(text: "text", importance: .usual, isMake: false))
    }
}
