import Foundation

struct Font {

  private static func construct(name: String, size: CGFloat) -> UIFont {
    return UIFont(name: name, size: size)!
  }

  struct HomeViewController {
    static var title: UIFont { return Font.construct("HelveticaNeue", size: 15) }
  }
}
