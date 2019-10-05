import UIKit

struct Screen {
    static var isPhone: Bool = {
        return UIDevice.current.userInterfaceIdiom == .phone
    }()

    static var isPad: Bool = {
        return UIDevice.current.userInterfaceIdiom == .pad
    }()

    static var height: CGFloat { return UIScreen.main.bounds.height }
    static var width: CGFloat { return UIScreen.main.bounds.width }
}
