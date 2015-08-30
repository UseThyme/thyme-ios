protocol Themable {
  var colors: [CGColor!] { get }
  var locations: [CGFloat] { get }
  var textColor: UIColor { get }
}

struct Theme {

  struct Main: Themable {
    var colors = [
      UIColor(hex: "37F7BA").CGColor,
      UIColor(hex: "05ABBF").CGColor,
      UIColor(hex: "0C80C3").CGColor
    ]
    var locations: [CGFloat] = [0.05,0.5,0.95]
    var textColor = UIColor(hex: "1B7F7D")
  }

  struct DarkColors: Themable {
    var colors = [
      UIColor(hex: "00FFE4").CGColor,
      UIColor(hex: "483076").CGColor
    ]
    var locations: [CGFloat] = [0.0,1.0]
    var textColor = UIColor(hex: "2F5686")
  }

  struct HighContrast: Themable {
    var colors = [
      UIColor(hex: "F7F7F7").CGColor,
      UIColor(hex: "D0D0D0").CGColor
    ]
    var locations: [CGFloat] = [0.0,1.0]
    var textColor = UIColor(hex: "1B807E")
  }

}
