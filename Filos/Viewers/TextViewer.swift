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
    
    @AppStorage("textViewerSize") var textViewerSize = 11
    @AppStorage("useMonospaced") var useMonospaced = true
    
    var fileURL: URL
    var fileLanguage: TreeSitterLanguage?
    
    @State private var file = clearFileItem
    @State private var fileText = ""
    @State private var editText = ""
    @State private var isEditing = true
    
    init(_ fileURL: URL) {
        self.fileURL = fileURL
        self.fileLanguage = getLanguage(fileURL)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if isEditing {
                    RunestoneEditor(text: $editText, language: fileLanguage)
                } else {
                    ScrollView {
                        Text(fileText)
                            .font(.system(size: CGFloat(textViewerSize), design: useMonospaced ? .monospaced : .default))
                            .padding(5)
                            .textSelection(.enabled)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 100, alignment: .topLeading)
            .navigationTitle(fileURL.deletingPathExtension().lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .noRefreshable()
            .safeAreaInset(edge: .bottom) {
                if !file.writable {
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
                    if isEditing {
                        Button {
                            isEditing = false
                            editText = fileText
                        } label: {
                            ToolbarLabel("Cancel", symbol: "xmark")
                        }
                    }
                    
                    Menu {
                        if file.writable && !isEditing {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        
                        Button {
                            Haptic.shared.play(.soft)
                            UIPasteboard.general.string = fileText
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            if let url = makeTemp(fileURL) {
                                presentShareSheet(with: url)
                            }
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button(role: .adaptiveConfirm) {
                            let res = writeTextIntoFile(fileURL, string: editText)
                            if res {
                                isEditing = false
                                fileText = getFileText(fileURL)
                            }
                        } label: {
                            ToolbarLabel("Save", symbol: "checkmark")
                        }
                    } else {
                        Button {
                            dismiss()
                            mgr.refreshFiles.toggle()
                        } label: {
                            ToolbarLabel("Close", symbol: "xmark")
                        }
                    }
                }
            }
            .onAppear {
                file = getFileItem(at: fileURL)
                let text = getFileText(fileURL)
                fileText = text
                editText = text
            }
        }
        .navigationViewStyle(.stack)
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

    private func getLanguage(_ url: URL) -> TreeSitterLanguage? {
        let ext = url.pathExtension.lowercased()
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

    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .systemBackground
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.showLineNumbers = true
        textView.editorDelegate = context.coordinator
        
        let state = getState()
        textView.setState(state)
        
        return textView
    }

    func updateUIView(_ uiView: TextView, context: Context) {
        if uiView.text != text {
            let state = getState()
            uiView.setState(state)
        }
    }

    func getState() -> TextViewState {
        if let language {
            return TextViewState(text: text, theme: DefaultTheme(), language: language)
        }
        return TextViewState(text: text, theme: DefaultTheme())
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
