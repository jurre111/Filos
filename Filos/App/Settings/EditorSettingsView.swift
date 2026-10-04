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
        List {
            Section {
                Toggle("Wrap Lines", isOn: $wrapLines)
                Toggle("Show Line Numbers", isOn: $lineNumbers)
                Toggle("Show Tabs", isOn: $showTabs)
                Toggle("Show Spaces", isOn: $showSpaces)
                Toggle("Show Line Breaks", isOn: $showLineBreaks)
                Toggle("Show Soft Line Breaks", isOn: $showSoftLineBreaks)
                Stepper(value: $lineHeight, in: 1.0...3.0, step: 0.1) {
                    HStack {
                        Text("Line height")
                        Spacer()
                        Text(String(format: "%.1f", lineHeight))
                    }
                }
            }
        }
        .navigationTitle("File Editor Settings")
    }
}