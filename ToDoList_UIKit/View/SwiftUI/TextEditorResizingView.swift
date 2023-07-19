//
//  TextEditorResizingView.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 16.07.2023.
//

import SwiftUI

struct TextEditorResizingView: View {
    
    @Binding var string: String
    @Binding var orientation: UIInterfaceOrientation
    let minHeightPortrait: CGFloat
    let minHeightLandscape: CGFloat
    @State var textEditorHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(string)
                .foregroundColor(.clear)
                .padding(10)
                .background(GeometryReader { geometryContent in
                    Color.clear.preference(
                        key: ViewHeightKey.self,
                        value: geometryContent.frame(in: .local).size.height
                    )
                })
            
            TextEditor(text: $string)
                .frame(height: max(
                    orientation.isPortrait ? minHeightPortrait : minHeightLandscape,
                    textEditorHeight
                ))
        }.onPreferenceChange(ViewHeightKey.self) {
            textEditorHeight = $0
        }
    }
    
}

private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
