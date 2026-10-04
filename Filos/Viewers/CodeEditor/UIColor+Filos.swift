import UIKit


extension UIColor {
    struct Filos {
        var background: UIColor {
            return getColor(light: (255, 255, 255), dark: (15, 15, 15))
        }
        var gutter: UIColor {
            return getColor(light: (248, 248, 248), dark: (10, 10, 10))
        }
        var selection: UIColor {
            return getColor(light: (229, 235, 241), dark: (43, 43, 43))
        }
        var currentLine: UIColor {
            return getColor(light: (248, 248, 248), dark: (20, 20, 20))
        }
        var foreground: UIColor {
            return getColor(light: (59, 59, 59), dark: (204, 204, 204))
        }
        var comment: UIColor {
            return getColor(light: (96, 139, 78), dark: (96, 139, 78))
        }
        var red: UIColor {
            return getColor(light: (249, 38, 114), dark: (249, 38, 114))
        }
        var orange: UIColor {
            return getColor(light: (214, 157, 133), dark: (214, 157, 133))
        }
        var yellow: UIColor {
            return getColor(light: (220, 220, 170), dark: (220, 220, 170))
        }
        var green: UIColor {
            return getColor(light: (181, 206, 168), dark: (181, 206, 168))
        }
        var aqua: UIColor {
            return getColor(light: (78, 201, 176), dark: (78, 201, 176))
        }
        var blue: UIColor {
            return getColor(light: (86, 156, 214), dark: (86, 156, 214))
        }
        var purple: UIColor {
            return getColor(light: (197, 134, 192), dark: (197, 134, 192))
        }
        var variable: UIColor {
            return getColor(light: (156, 220, 254), dark: (156, 220, 254))
        }


        fileprivate init() {}

        private func getColor(light: (red: CGFloat, green: CGFloat, blue: CGFloat), dark: (red: CGFloat, green: CGFloat, blue: CGFloat)) -> UIColor {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: dark.red / 255, green: dark.green / 255, blue: dark.blue / 255, alpha: 1)
                } else {
                    return UIColor(red: light.red / 255, green: light.green / 255, blue: light.blue / 255, alpha: 1)
                }
            }
        }
    }


    static let filos = Filos()
}