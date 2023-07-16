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
    @State private var text = ""
    @State private var orientation: UIInterfaceOrientation = .unknown
    @FocusState private var focus: Focus?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    let textEditor = TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .scrollDisabled(true)
                        .background(.background)
                        .cornerRadius(16)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: orientation.isPortrait ? 120 : proxy.size.height - 32
                        )
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("Что надо сделать?")
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                    .padding(.top, 12)
                                    .font(Font.custom("SF Pro Text", size: 17))
                                    .foregroundColor(.black.opacity(0.3))
                            }
                        }
                        .focused($focus, equals: .textEditor)
                        .onTapGesture {
                            focus = .textEditor
                        }
                    if orientation.isPortrait {
                        VStack(alignment: .leading) {
                            Text("dsf")
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.background, lineWidth: 2)
                                )
                            Text("dfs")
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.background, lineWidth: 2)
                                )
                        }.background(.background)
                            .cornerRadius(16)
                        
                        Button {
                            
                        } label: {
                            Text("Удалить")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.background, lineWidth: 2)
                                )
                        }.background(.background)
                            .cornerRadius(16)
                        Spacer()
                    }
                }
            }.ignoresSafeArea()
                .padding(16)
                .background(
                    colorScheme == .light ?
                    Color(red: 0.97, green: 0.97, blue: 0.95) : Color(red: 0.09, green: 0.09, blue: 0.09)
                )
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    guard let windowScene else {
                        return
                    }
                    orientation = windowScene.interfaceOrientation
                }
                .onTapGesture {
                    guard let focus else {
                        return
                    }
                    self.focus = nil
                }
        }
    }
}

struct TodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemView()
    }
}
