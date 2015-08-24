import UIKit

struct Screen {

  static var isPhone: Bool = {
    return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }()

  static var isPad: Bool = {
    return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }()

}
