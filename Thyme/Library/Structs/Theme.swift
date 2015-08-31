protocol Themable {
  var name: ThemeName { get }
  var colors: [CGColor!] { get }
  var locations: [CGFloat] { get }
  var textColor: UIColor { get }
  var labelColor: UIColor { get }
  var circleActive: UIColor { get }
  var circleActiveHours: UIColor { get }
  var circleInactive: UIColor { get }
  var circleOutlineActive: UIColor { get }
  var circleOutlineInactive: UIColor { get }
}

enum ThemeName {
  case ThePacific, MidnightBlue, Noir
}

struct Theme {

  struct Main: Themable {
    var name = ThemeName.ThePacific
    var colors = [
      UIColor(hex: "37F7BA").CGColor,
      UIColor(hex: "05ABBF").CGColor,
      UIColor(hex: "0C80C3").CGColor
    ]
    var locations: [CGFloat] = [0.05,0.5,0.95]
    var textColor = UIColor(hex: "1B7F7D")
    var labelColor = UIColor(hex: "FFFFFF")
    var circleActive = UIColor(hex: "4EE5E6")
    var circleActiveHours = UIColor(hex: "4EE5E6")
    var circleInactive = UIColor(white: 1.0, alpha: 0.4)
    var circleOutlineActive = UIColor.whiteColor()
    var circleOutlineInactive = UIColor.clearColor()
  }

  struct DarkColors: Themable {
    var name = ThemeName.MidnightBlue
    var colors = [
      UIColor(hex: "00FFE4").CGColor,
      UIColor(hex: "483076").CGColor
    ]
    var locations: [CGFloat] = [0.0,1.0]
    var textColor = UIColor(hex: "2F5686")
    var labelColor = UIColor(hex: "FFFFFF")
    var circleActive = UIColor(hex: "39C7D5")
    var circleActiveHours = UIColor(hex: "39C7D5")
    var circleInactive = UIColor(white: 1.0, alpha: 0.4)
    var circleOutlineActive = UIColor.whiteColor()
    var circleOutlineInactive = UIColor.clearColor()
  }

  struct HighContrast: Themable {
    var name = ThemeName.Noir
    var colors = [
      UIColor(hex: "F7F7F7").CGColor,
      UIColor(hex: "D0D0D0").CGColor
    ]
    var locations: [CGFloat] = [0.0,1.0]
    var textColor = UIColor(hex: "000000")
    var labelColor = UIColor(hex: "000000")
    var circleActive = UIColor(hex: "BDBDBD")
    var circleActiveHours = UIColor(hex: "BDBDBD")
    var circleInactive = UIColor(red: 255, green: 255, blue: 255, alpha: 0.4)
    var circleOutlineActive = UIColor.blackColor()
    var circleOutlineInactive = UIColor(hex: "BCBCBC")
  }

}
