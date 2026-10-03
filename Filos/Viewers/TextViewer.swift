//
//  TextViewer.swift
//  Filos
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI
import Runestone
import TreeSitterJSONRunestone


struct TextViewer: View {
    @EnvironmentObject var mgr: FilosManager
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("textViewerSize") var textViewerSize = 11
    @AppStorage("useMonospaced") var useMonospaced = true
    
    var fileURL: URL
    
    @State private var file = clearFileItem
    @State private var fileText = ""
    @State private var editText = ""
    @State private var isEditing = true
    
    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if isEditing {
                    RunestoneEditor(text: $editText)
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
}

struct RunestoneEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .systemBackground
        textView.showLineNumbers = true
        textView.editorDelegate = context.coordinator
        
        let state = TextViewState(text: text, theme: DefaultTheme(), language: .json)
        textView.setState(state)
        
        return textView
    }

    func updateUIView(_ uiView: TextView, context: Context) {
        if uiView.text != text {
            let state = TextViewState(text: text, theme: DefaultTheme(), language: .json)
            uiView.setState(state)
        }
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
