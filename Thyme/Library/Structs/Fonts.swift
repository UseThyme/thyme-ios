import Foundation

enum DynamicSize: String {
  case XSmall = "UICTContentSizeCategoryXS"
  case Small = "UICTContentSizeCategoryS"
  case Medium = "UICTContentSizeCategoryM"
  case Large = "UICTContentSizeCategoryL"
  case XLarge = "UICTContentSizeCategoryXL"
  case XXLarge = "UICTContentSizeCategoryXXL"
  case XXXLarge = "UICTContentSizeCategoryXXXL"
}

struct Font {

  private static var ContentSize: String { return UIApplication.sharedApplication().preferredContentSizeCategory }

  static func dynamicSize(size: CGFloat) -> CGFloat {
    var calculatedSize = size

    switch(Device(rawValue: Screen.height)!) {
    case .iPhone6:     calculatedSize += 1
    case .iPhone6Plus: calculatedSize += 2
    default: break
    }

    switch(DynamicSize(rawValue: ContentSize)!) {
    case .XSmall: calculatedSize -= 2
    case .Small:     calculatedSize -= 1
    case .Medium:    calculatedSize -= 0
    case .Large:     calculatedSize += 1
    case .XLarge: calculatedSize += 2
    case .XXLarge: calculatedSize += 3
    case .XXXLarge: calculatedSize += 4
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

  struct Instruction {
    static var title: UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(27)) }
    static var message: UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(14)) }
    static var acceptButton: UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(15)) }
    static var previousButton: UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(15)) }
    static var nextButton: UIFont { return UIFont.systemFontOfSize(Font.dynamicSize(15)) }
  }

  struct Settings {
    static var headerLabel: UIFont { return UIFont.boldSystemFontOfSize(Font.dynamicSize(18)) }
    static var textLabel: UIFont { return UIFont.boldSystemFontOfSize(Font.dynamicSize(16)) }
  }
}
