//
//  EditorSettingsView.swift
//  Filos
//
//  Created by jurre111 on 10/4/26.
//

import SwiftUI


struct EditorSettingsView: View {
    @AppStorage("wrapLines") var wrapLines = false
    @AppStorage("lineNumbers") var lineNumbers = true
    @AppStorage("showTabs") var showTabs = false
    @AppStorage("showSpaces") var showSpaces = false
    @AppStorage("showLineBreaks") var showLineBreaks = false
    @AppStorage("showSoftLineBreaks") var showSoftLineBreaks = false
    @AppStorage("lineHeight") var lineHeight = 1.0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Wrap Lines", isOn: $wrapLines)
                    Toggle("Show Line Numbers", isOn: $lineNumbers)
                    Toggle("Show Tabs", isOn: $showTabs)
                    Toggle("Show Spaces", isOn: $showSpaces)
                    Toggle("Show Line Breaks", isOn: $showLineBreaks)
                    Toggle("Show Soft Line Breaks", isOn: $showSoftLineBreaks)
                    Stepper(value: $lineHeight, in: 0.5...2.0, step: 0.1) {
                        HStack {
                            Text("Line height")
                            Spacer()
                            Text(lineHeight.description)
                        }
                    }
                }
            }
            .navigationTitle("File Editor Settings")
            .navigationBarTitleDisplayMode(.inline)
            .noRefreshable()
        }
        .navigationViewStyle(.stack)
    }
}