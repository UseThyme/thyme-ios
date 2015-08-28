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

  private static func construct(name: String, size: CGFloat) -> UIFont {
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

    return UIFont(name: name, size: calculatedSize)!
  }

  struct HomeViewController {
    static var title: UIFont { return Font.construct("HelveticaNeue", size: 15) }
    static var subtitle: UIFont { return Font.construct("HelveticaNeue-Bold", size: 19) }
  }

  struct TimerControl {
    static func hoursLabel(fontSize: CGFloat) -> UIFont { return Font.construct("HelveticaNeue-Bold", size: fontSize) }
    static func minutesValueLabel(fontSize: CGFloat) -> UIFont { return Font.construct("HelveticaNeue", size: fontSize) }
    static func minutesTitleLabel(fontSize: CGFloat) -> UIFont { return Font.construct("HelveticaNeue", size: fontSize) }
    static var arcText: UIFont { return Font.construct("HelveticaNeue", size: 14) }
  }

  struct Instruction {
    static var title: UIFont { return Font.construct("HelveticaNeue-Medium", size: 27) }
    static var message: UIFont { return Font.construct("HelveticaNeue-Medium", size: 14) }
    static var acceptButton: UIFont { return Font.construct("HelveticaNeue-Medium", size: 15) }
    static var previousButton: UIFont { return Font.construct("HelveticaNeue-Medium", size: 15) }
    static var nextButton: UIFont { return Font.construct("HelveticaNeue-Medium", size: 15) }
  }

  struct Settings {
    static var headerLabel: UIFont { return Font.construct("HelveticaNeue-Bold", size: 18) }
    static var textLabel: UIFont { return Font.construct("HelveticaNeue-Medium", size: 16) }
  }
}
