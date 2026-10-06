//
//  PlistViewer.swift
//  Filos
//
//  Created by lunginspector on 7/25/26.
//

import SwiftUI


struct PlistViewer: View {
    @StateObject private var pmgr = PlistManager.shared
    @EnvironmentObject var mgr: FilosManager
    @Environment(\.dismiss) var dismiss
    @State private var fileURL: URL
    
    @State private var file = clearFileItem
    @State private var showErrorView = false
    
    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }
    
    var body: some View {
        NavigationView {
            List {
                if showErrorView {
                    PlainAlert(title: "Failed to load plist!", symbol: "exclamationmark.triangle.fill", text: Errors.checkLogs, color: .yellow)
                } else {
                    ForEach($pmgr.plistArray) { $item in
                        ItemRow(item: $item, hierarchy: 0)
                            .environmentObject(pmgr)
                    }
                }
            }
            .navigationTitle(file.fileURL.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.inset)
            .noRefreshable()
            .safeAreaInset(edge: .bottom) {
                if !pmgr.isWritable {
                    HStack {
                        Spacer()
                        Button {
                            Alertinator.shared.alert(title: "View-Only File", body: "You can only read this file.")
                        } label: {
                            Image(systemName: "lock")
                                .padding(10)
                        }
                        .foregroundStyle(.accent)
                        .padding(.trailing)
                        .ignoresSafeArea()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        ToolbarLabel("Close", symbol: "xmark")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Menu {
                        Button {
                            if let url = makeTemp(file.fileURL) {
                                presentShareSheet(with: url)
                            }
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button {
                            Alertinator.shared.prompt(title: "What would you like to call this file?", text: file.name, completion: { result in
                                if let name = result {
                                    let res = renameFile(fileURL, to: name)
                                    if res {
                                        file.name = name
                                        mgr.refreshFiles = fileURL.deletingLastPathComponent()
                                        fileURL = fileURL.deletingLastPathComponent().appendingPathComponent(name)
                                    } else {
                                        Alertinator.shared.alert(title: "Failed to rename file!", body: Errors.checkLogs)
                                    }
                                }
                            })
                        } label: {
                            Label("Rename", systemImage: "applepencil")
                                .foregroundStyle(file.writable ? .primary : .secondary)
                        }
                        .disabled(!file.writable)
                    } label: {
                        HStack(alignment: .center, spacing: 6) {
                            Text(fileURL.deletingPathExtension().lastPathComponent)
                                .font(.headline)
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.footnote.bold())
                                .foregroundStyle(.secondary)
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .tint(.primary)
                }
            }
        }
        .onAppear {
            pmgr.url = fileURL
            file = getFileItem(at: fileURL)
            let res = pmgr.loadPlistItems()
            if !res {
                showErrorView = true
            }
            pmgr.isWritable = file.writable
        }
        .navigationViewStyle(.stack)
    }
}

// no comment.
extension UIColor {
    static func hierarchyLevelColor(_ level: Int = 0) -> UIColor {
        UIColor { trait in
            let isDark = (trait.userInterfaceStyle == .dark)
            let baseColor = isDark ? UIColor.secondarySystemBackground.resolvedColor(with: trait) : UIColor.white.resolvedColor(with: trait)
            
            let clampedLevel = max(0, level)
            var factor = max(0, 1 - 0.03 * CGFloat(clampedLevel))
            if isDark {
                factor = max(0, 1 + 0.24 * CGFloat(clampedLevel))
            }

            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0

            if baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
                let newBrightness = max(0, min(1, b * factor))
                return UIColor(hue: h, saturation: s, brightness: newBrightness, alpha: a)
            }

            var r: CGFloat = 0
            var g: CGFloat = 0
            var bl: CGFloat = 0

            guard baseColor.getRed(&r, green: &g, blue: &bl, alpha: &a) else {
                return baseColor
            }

            return UIColor(red: max(0, r * factor), green: max(0, g * factor), blue: max(0, bl * factor), alpha: a)
        }
    }
}
