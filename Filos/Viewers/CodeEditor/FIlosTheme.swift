//
//  EditorSettingsView.swift
//  Filos
//
//  Created by jurre111 on 10/3/26.
//

import Runestone
import UIKit


class FilosTheme: Theme {
    let font: UIFont
    let textColor: UIColor = .filos.foreground


    let gutterBackgroundColor: UIColor = .filos.gutter
    let gutterHairlineColor: UIColor = .filos.gutter


    let lineNumberColor: UIColor = .filos.foreground
    let lineNumberFont: UIFont


    let selectedLineBackgroundColor: UIColor = .filos.currentLine
    let selectedLinesLineNumberColor: UIColor = .filos.foreground
    let selectedLinesGutterBackgroundColor: UIColor = .filos.background


    let invisibleCharactersColor: UIColor = .filos.comment


    let pageGuideHairlineColor: UIColor = .filos.foreground.withAlphaComponent(0.1)
    let pageGuideBackgroundColor: UIColor = .filos.foreground.withAlphaComponent(0.2)


    let markedTextBackgroundColor: UIColor = .filos.foreground.withAlphaComponent(0.2)

    init() {
        let fontSize = UserDefaults.standard.object(forKey: "textViewerSize") as? CGFloat ?? 11
        let useMonospaced = UserDefaults.standard.object(forKey: "useMonospaced") as? Bool ?? true
        font = useMonospaced ? .monospacedSystemFont(ofSize: fontSize, weight: .regular) : .systemFont(ofSize: fontSize, weight: .regular)
        lineNumberFont = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }

    func textColor(for highlightName: String) -> UIColor? {
        guard let highlightName = HighlightName(highlightName) else {
            return nil
        }
        switch highlightName {
        case .comment:
            return .filos.comment
        case .constructor:
            return .filos.yellow
        case .function:
            return .filos.yellow
        case .keyword:
            return .filos.purple
        case .type:
            return .filos.aqua
        case .number, .constantBuiltin, .constantCharacter:
            return .filos.green
        case .property:
            return .filos.variable
        case .string:
            return .filos.orange
        case .variableBuiltin:
            return .filos.blue
        case .operator, .punctuation:
            return .filos.foreground
        case .variable:
            return .filos.variable
        }
    }

    func fontTraits(for highlightName: String) -> FontTraits {
        guard let highlightName = HighlightName(highlightName) else {
            return []
        }
        if highlightName == .keyword {
            return .bold
        } else {
            return []
        }
    }
}