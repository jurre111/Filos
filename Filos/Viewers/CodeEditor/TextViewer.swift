//
//  TextViewer.swift
//  Filos
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI
import Runestone
import TreeSitterJSONRunestone
import TreeSitterBashRunestone
import TreeSitterCRunestone
import TreeSitterCSharpRunestone
import TreeSitterCPPRunestone
import TreeSitterCSSRunestone
import TreeSitterHTMLRunestone
import TreeSitterJavaRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterMarkdownRunestone
import TreeSitterPythonRunestone
import TreeSitterSwiftRunestone
import TreeSitterYAMLRunestone


struct TextViewer: View {
    @EnvironmentObject var mgr: FilosManager
    @Environment(\.dismiss) var dismiss
    
    @State var fileURL: URL
    @State var fileLanguage: String = ""
    
    @State private var file = clearFileItem
    @State private var fileText = ""
    @State private var editText = ""
    
    
    var body: some View {
        NavigationView {
            RunestoneEditor(text: $editText, language: getLanguage(fileLanguage), editable: $file.writable)
                .ignoresSafeArea(.container, edges: .bottom)
                .navigationBarTitleDisplayMode(.inline)
            // .safeAreaInset(edge: .bottom) {
            //     if !file.writable {
            //         HStack {
            //             Spacer()
            //             Button {
            //                 Alertinator.shared.alert(title: "View-Only File", body: "You can only read this file.")
            //             } label: {
            //                 Image(systemName: "lock")
            //                     .padding(10)
            //             }
            //             .foregroundStyle(.accent)
            //             .padding(.trailing)
            //             .ignoresSafeArea()
            //         }
            //     }
            // }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            editText = fileText
                            dismiss()
                        } label: {
                            Text("Close")
                                .bold()
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        Menu {
                            Picker(selection: $fileLanguage) {
                                Text("Plain Text").tag("")
                                Text("JSON").tag("json")
                                Text("Bash").tag("sh")
                                Text("C").tag("c")
                                Text("C++").tag("cpp")
                                Text("C#").tag("cs")
                                Text("CSS").tag("css")
                                Text("HTML").tag("html")
                                Text("Java").tag("java")
                                Text("JavaScript").tag("js")
                                Text("Markdown").tag("md")
                                Text("Python").tag("py")
                                Text("Swift").tag("swift")
                                Text("YAML").tag("yaml")
                            } label: {
                                Label("Language", systemImage: "character.book.closed")
                            }
                            Button {
                                if let url = makeTemp(fileURL) {
                                    presentShareSheet(with: url)
                                }
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            Button {
                                Haptic.shared.play(.soft)
                                UIPasteboard.general.string = fileText
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            Button {
                                Alertinator.shared.prompt(title: "What would you like to call this file?", text: file.name, completion: { result in
                                    if let name = result {
                                        let res = renameFile(fileURL, to: name)
                                        if res {
                                            file.name = name
                                            fileURL = fileURL.deletingLastPathComponent().appendingPathComponent(name)
                                            mgr.refreshFiles.toggle()
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
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .adaptiveConfirm) {
                            let res = writeTextIntoFile(fileURL, string: editText)
                            if res {
                                fileText = getFileText(fileURL)
                            }
                        } label: {
                            Text("Save")
                                .bold()
                                .foregroundStyle(file.writable ? .accent : .secondary)
                        }
                        .disabled(!file.writable)
                    }
                }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            file = getFileItem(at: fileURL)
            let text = getFileText(fileURL)
            fileText = text
            editText = text

            if getLanguage(fileURL.pathExtension.lowercased()) != nil {
                fileLanguage = fileURL.pathExtension.lowercased()
            }
        }
    }
    
    private func writeTextIntoFile(_ url: URL, string: String) -> Bool {
        do {
            let data = Data(string.utf8)
            try data.write(to: url)
            return true
        } catch {
            print("[!] failed to write data: \(error)")
        }
        return false
    }

    private func getLanguage(_ ext: String) -> TreeSitterLanguage? {
        switch ext {
        case "json":
            return .json
        case "sh", "bash":
            return .bash
        case "c":
            return .c
        case "cpp", "cxx", "cc", "hpp", "hxx", "hh":
            return .cpp
        case "cs":
            return .cSharp
        case "css":
            return .css
        case "html", "htm":
            return .html
        case "java":
            return .java
        case "js", "jsx":
            return .javaScript
        case "md", "markdown":
            return .markdown
        case "py":
            return .python
        case "swift":
            return .swift
        case "yaml", "yml":
            return .yaml
        default:
            return nil
        }
    }
}

struct RunestoneEditor: UIViewRepresentable {
    @Binding var text: String
    var language: TreeSitterLanguage?
    @Binding var editable: Bool

    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .filos.background
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.isLineWrappingEnabled = UserDefaults.standard.object(forKey: "wrapLines") as? Bool ?? false
        textView.showLineNumbers = UserDefaults.standard.object(forKey: "lineNumbers") as? Bool ?? true
        textView.showTabs = UserDefaults.standard.object(forKey: "showTabs") as? Bool ?? false
        textView.showSpaces = UserDefaults.standard.object(forKey: "showSpaces") as? Bool ?? false
        textView.showLineBreaks = UserDefaults.standard.object(forKey: "showLineBreaks") as? Bool ?? false
        textView.showSoftLineBreaks = UserDefaults.standard.object(forKey: "showSoftLineBreaks") as? Bool ?? false
        textView.lineHeightMultiplier = UserDefaults.standard.object(forKey: "lineHeight") as? Double ?? 1.0
        textView.editorDelegate = context.coordinator
        textView.isEditable = editable
        
        let state = getState()
        textView.setState(state)
        
        return textView
    }

    func updateUIView(_ uiView: TextView, context: Context) {
        if uiView.isEditable != editable {
            uiView.isEditable = editable
        }
        if uiView.text != text {
            let state = getState()
            uiView.setState(state)
        }
    }

    func getState() -> TextViewState {
        if let language {
            return TextViewState(text: text, theme: FilosTheme(), language: language)
        }
        return TextViewState(text: text, theme: FilosTheme())
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, TextViewDelegate {
        var parent: RunestoneEditor

        init(_ parent: RunestoneEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: TextView) {
            parent.text = textView.text
        }
    }
}
