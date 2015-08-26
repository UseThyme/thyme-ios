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

    println(ContentSize)

    switch(DynamicSize(rawValue: ContentSize)!) {
    case .XSmall: calculatedSize -= 2
    case .Small:     calculatedSize -= 1
    case .Medium:    calculatedSize -= 0
    case .Large:     calculatedSize += 1
    case .XLarge: calculatedSize += 2
    case .XXLarge: calculatedSize += 2
    case .XXXLarge: calculatedSize += 2
    }

    return UIFont(name: name, size: calculatedSize)!
  }

  struct HomeViewController {
    static var title: UIFont { return Font.construct("HelveticaNeue", size: 15) }
  }
}
