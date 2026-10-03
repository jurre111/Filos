import UIKit


extension UIColor {
    struct Filos {
        var background: UIColor {
            return .secondarySystemBackground
        }
        var selection: UIColor {
            return UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
        }
        var currentLine: UIColor {
            return UIColor(red: 15 / 255, green: 15 / 255, blue: 15 / 255, alpha: 1)
        }
        var foreground: UIColor {
            return UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
        }
        var comment: UIColor {
            return UIColor(red: 96 / 255, green: 139 / 255, blue: 78 / 255, alpha: 1)
        }
        var red: UIColor {
            return UIColor(red: 249 / 255, green: 38 / 255, blue: 114 / 255, alpha: 1)
        }
        var orange: UIColor {
            return UIColor(red: 214 / 255, green: 157 / 255, blue: 133 / 255, alpha: 1)
        }
        var yellow: UIColor {
            return UIColor(red: 220 / 255, green: 220 / 255, blue: 170 / 255, alpha: 1)
        }
        var green: UIColor {
            return UIColor(red: 181 / 255, green: 206 / 255, blue: 168 / 255, alpha: 1)
        }
        var aqua: UIColor {
            return UIColor(red: 78 / 255, green: 201 / 255, blue: 176 / 255, alpha: 1)
        }
        var blue: UIColor {
            return UIColor(red: 86 / 255, green: 156 / 255, blue: 214 / 255, alpha: 1)
        }
        var purple: UIColor {
            return UIColor(red: 197 / 255, green: 134 / 255, blue: 192 / 255, alpha: 1)
        }
        var variable: UIColor {
            return UIColor(red: 156 / 255, green: 220 / 255, blue: 254 / 255, alpha: 1)
        }


        fileprivate init() {}
    }


    static let filos = Filos()
}