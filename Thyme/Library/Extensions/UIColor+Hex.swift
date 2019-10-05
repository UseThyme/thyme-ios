import UIKit

extension UIColor {
    public convenience init(hex: String) {
        let noHasString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: noHasString)
        scanner.charactersToBeSkipped = CharacterSet.symbols

        var hexInt: UInt32 = 0
        if scanner.scanHexInt32(&hexInt) {
            let red = (hexInt >> 16) & 0xFF
            let green = (hexInt >> 8) & 0xFF
            let blue = hexInt & 0xFF

            self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        } else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }
    }

    public class func colorFromHex(_ hex: String) -> UIColor {
        return UIColor(hex: hex)
    }
}
