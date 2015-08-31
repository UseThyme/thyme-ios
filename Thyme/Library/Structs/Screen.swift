import UIKit

struct Screen {

  static var isPhone: Bool = {
    return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }()

  static var isPad: Bool = {
    return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }()

  static var height: CGFloat { return UIScreen.mainScreen().bounds.height }
  static var width: CGFloat { return UIScreen.mainScreen().bounds.width }
}
