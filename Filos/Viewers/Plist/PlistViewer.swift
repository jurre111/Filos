//
//  PlistViewer.swift
//  Filos
//
//  Created by lunginspector on 7/25/26.
//

import SwiftUI


struct PlistViewer: View {
    @EnvironmentObject var mgr: FilosManager
    @Environment(\.dismiss) var dismiss
    @State private var fileURL: URL
    @State private var dict: [String: Any] = [:]
    
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
                    PlistGroup(key: "Root", value: dict, path: [], dict: $dict, keyEditable: false)
                }
            }
            .navigationTitle(file.fileURL.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.inset)
            .noRefreshable()
            .safeAreaInset(edge: .bottom) {
                if file.isWritable {
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
            file = getFileItem(at: fileURL)
            let res = loadPlistItems()
            if !res {
                showErrorView = true
            }
        }
        .navigationViewStyle(.stack)
    }

    func loadPlistItems() -> Bool {
        if let rawDict = getFileDict(url) {
            dict = rawDict
            return true
        } else {
            print("[!] failed to load plist as it seems like there was no passable dictionary?")
        }
        return false
    }
}

struct DictView: View {
    @Binding var dict: [String: Any]
    let path: [String]
    @State private var keys: [String] = []

    var body: some View {
        ForEach(keys, id: \.self) { key in
            let value = getDictValue(dict, path + [key]) ?? "huh?"
            PlistGroup(key: key, value: value, path: path + [key], dict: $dict)
        }
        .onAppear {
            if let value = getDictValue(dict, path) as? [String: Any] {
                keys = value.keys.sorted()
            }
        }
    }
}

func getType(_ value: Any) -> PlistItemType {
    switch value {
    case is String: return .string
    case is Int: return .int
    case is Double: return .double
    case is Bool: return .bool
    case is Data: return .data
    case is [String : Any]: return .dict
    case is [Any]: return .array
    default: return .unknown
    }
}

func getDictValue(dict: [String: Any], path: [Any]) -> Any? {
    guard !path.isEmpty else { return dict }

    var currentDict: [String: Any] = dict
    for component in path.dropLast() {
        if let nextDict = currentDict[component] as? [String: Any] {
            currentDict = nextDict
        } else {
            return nil
        }
    }
    return currentDict[path.last!]
}

func getStringValue(_ value: Any) -> String {
    switch value {
    case let v as String: return v
    case let v as Int: return String(v)
    case let v as Double: return String(v)
    case let v as Bool: return String(v)
    case let v as Data: return v.base64EncodedString()
    case let v as [String: Any]: return v.description
    case let v as [Any]: return v.description
    default: return ""
    }
}

struct PlistGroup: View {
    let key: String
    let value: Any
    let type: PlistItemType
    let path: [String]
    let hierarchy: Int = 0
    let stringVal: String
    let keyEditable: Bool

    @State private var isExpanded: Bool = false
    @Binding var dict: [String: Any]

    init(key: String, value: Any, path: [String], dict: Binding<[String: Any]>, keyEditable: Bool = true) {
        self.key = key
        self.value = value
        self.type = getType(value)
        self.path = path
        self.hierarchy = path.count
        self.stringVal = getStringValue(value)
        self.keyEditable = keyEditable
        self._dict = dict
    }

    var body: some View {
        if type == .dict || type == .array || type == .data {
            HStack {
                Button {
                    isExpanded.toggle()
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                            .font(.body.weight(.semibold))
                            .imageScale(.small)
                            .rotationEffect(.degrees(isExpanded ? 0 : -90))
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                        Text(key)
                            .lineLimit(1)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                if type != .data {
                    Text("\(type.label) (\(value.count.description))")
                } else {
                    Text(type.label)
                }
                Image(systemName: "info.circle")
                    .overlay {
                        NavigationLink(destination: ModifyItemPage(dict: $dict, path: path, keyEditable: keyEditable)) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
            }
            .listRowBackground(Color(uiColor: .hierarchyLevelColor(hierarchy)))
            // dictionary inception time
            if isExpanded {
                if type == .dict {
                    DictView(dict: $dict, path: path)
                } else if type == .array {
                    if let array = value as? [Any] {
                        ForEach(array.indices, id: \.self) { index in
                            let itemValue = array[index]
                            PlistGroup(key: "Item \(index)", value: itemValue, path: path + ["Item \(index)"], dict: $dict, keyEditable: false)
                        }
                    }
                } else if type == .data {
                    Text(stringVal)
                        .font(.system(size: 12, design: .monospaced))
                        .lineLimit(12)
                        .listRowBackground(Color(uiColor: .hierarchyLevelColor(hierarchy + 1)))
                        .overlay {
                            NavigationLink(destination: ModifyItemPage(dict: $dict, path: path, keyEditable: keyEditable)) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                }
            }
        } else {
            NavigationLink(destination: ModifyItemPage(dict: $dict, path: path, keyEditable: keyEditable)) {
                HStack {
                    Text(key)
                        .lineLimit(1)
                    Spacer()
                    Text(stringVal)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
            .listRowBackground(Color(uiColor: .hierarchyLevelColor(hierarchy)))
        }
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
