import UIKit

extension UIColor {
    static let yaBlack = UIColor(named: "Black")!
    static let yAGray = UIColor(named: "Gray")!
    static let yaLightGray = UIColor(named: "Light Gray")!
    static let yaWhite = UIColor(named: "White")!
    static let background = UIColor(named: "Background")!
    static let yaRed = UIColor(named: "Red")!
    static let yaBlue = UIColor(named: "Blue")!
    static let fullBlack = UIColor(named: "Full Black")!
    static let fullWhite = UIColor(named: "Full White")!
    static let blackDay = UIColor(named: "Black Day")!
    static let yaDatePickerColor = UIColor(named: "datePickerColor")!
    
    static let selection = [
        UIColor(named: "Color selection 1")!,
        UIColor(named: "Color selection 2")!,
        UIColor(named: "Color selection 3")!,
        UIColor(named: "Color selection 4")!,
        UIColor(named: "Color selection 5")!,
        UIColor(named: "Color selection 6")!,
        UIColor(named: "Color selection 7")!,
        UIColor(named: "Color selection 8")!,
        UIColor(named: "Color selection 9")!,
        UIColor(named: "Color selection 10")!,
        UIColor(named: "Color selection 11")!,
        UIColor(named: "Color selection 12")!,
        UIColor(named: "Color selection 13")!,
        UIColor(named: "Color selection 14")!,
        UIColor(named: "Color selection 15")!,
        UIColor(named: "Color selection 16")!,
        UIColor(named: "Color selection 17")!,
        UIColor(named: "Color selection 18")!,
    ]
}

extension UIColor {
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formattedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if formattedString.hasPrefix("#") {
            formattedString.remove(at: formattedString.startIndex)
        }
        
        guard let hexValue = UInt32(formattedString, radix: 16) else {
            return nil
        }
        
        let red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
