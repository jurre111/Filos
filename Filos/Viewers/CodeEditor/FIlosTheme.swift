import Runestone
import UIKit


class FilosTheme: Theme {
    let fontSize: CGFloat = UserDefaults.standard.object(forKey: "textViewerSize") as? CGFloat ?? 11
    let font: UIFont = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
    let textColor: UIColor = .filos.foreground


    let gutterBackgroundColor: UIColor = .filos.background
    let gutterHairlineColor: UIColor = .filos.background


    let lineNumberColor: UIColor = .filos.foreground
    let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: fontSize, weight: .regular)


    let selectedLineBackgroundColor: UIColor = .filos.currentLine
    let selectedLinesLineNumberColor: UIColor = .filos.foreground
    let selectedLinesGutterBackgroundColor: UIColor = .filos.background


    let invisibleCharactersColor: UIColor = .filos.comment


    let pageGuideHairlineColor: UIColor = .filos.foreground.withAlphaComponent(0.1)
    let pageGuideBackgroundColor: UIColor = .filos.foreground.withAlphaComponent(0.2)


    let markedTextBackgroundColor: UIColor = .filos.foreground.withAlphaComponent(0.2)

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