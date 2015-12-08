import Foundation

enum DynamicSize: String {
  case XSmall = "UICTContentSizeCategoryXS"
  case Small = "UICTContentSizeCategoryS"
  case Medium = "UICTContentSizeCategoryM"
  case Large = "UICTContentSizeCategoryL"
  case XLarge = "UICTContentSizeCategoryXL"
  case XXLarge = "UICTContentSizeCategoryXXL"
  case XXXLarge = "UICTContentSizeCategoryXXXL"
  case AccessibilityM = "UICTContentSizeCategoryAccessibilityM"
  case AccessibilityL = "UICTContentSizeCategoryAccessibilityL"
  case AccessibilityXL = "UICTContentSizeCategoryAccessibilityXL"
  case AccessibilityXXL = "UICTContentSizeCategoryAccessibilityXXL"
  case AccessibilityXXXL = "UICTContentSizeCategoryAccessibilityXXXL"
}

struct Font {

  private static var ContentSize: String { return UIApplication.sharedApplication().preferredContentSizeCategory }

  static func dynamicSize(size: CGFloat) -> CGFloat {
    var calculatedSize = size

    if let device = Device(rawValue: Float(Screen.height)) {
      switch(device) {
      case .iPhone6:     calculatedSize += 1
      case .iPhone6Plus: calculatedSize += 2
      default: break
      }
    }

    guard let dynamicSize = DynamicSize(rawValue: ContentSize) else {
      return calculatedSize
    }

    switch(dynamicSize) {
    case .XSmall:   calculatedSize -= 3
    case .Small:    calculatedSize -= 2
    case .Medium:   calculatedSize -= 1
    case .Large:    calculatedSize += 0
    case .XLarge:   calculatedSize += 2
    case .XXLarge:  calculatedSize += 3
    case .XXXLarge: calculatedSize += 4
    case .AccessibilityM: calculatedSize += 5
    case .AccessibilityL: calculatedSize += 6
    case .AccessibilityXL: calculatedSize += 7
    case .AccessibilityXXL: calculatedSize += 8
    case .AccessibilityXXXL: calculatedSize += 9
    }
    
    return calculatedSize
  }

  struct HomeViewController {
    static var title: UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(15)) }
    static var subtitle: UIFont { return UIFont.boldSystemFontOfSize(Font.dynamicSize(19)) }
  }

  struct TimerControl {
    static func hoursLabel(fontSize: CGFloat) -> UIFont { return UIFont.boldSystemFontOfSize(Font.dynamicSize(fontSize)) }
    static func minutesValueLabel(fontSize: CGFloat) -> UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(fontSize)) }
    static func minutesTitleLabel(fontSize: CGFloat) -> UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(fontSize)) }
    static var arcText: UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(14)) }
  }

  struct Herbie {
    static var title: UIFont { return UIFont.boldSystemFontOfSize(Font.dynamicSize(30)) }
  }

  struct Settings {
    static var headerLabel: UIFont { return UIFont.boldSystemFontOfSize(Font.dynamicSize(18)) }
    static var textLabel: UIFont { return UIFont.boldSystemFontOfSize(Font.dynamicSize(16)) }
  }
}
