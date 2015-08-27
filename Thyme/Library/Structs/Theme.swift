struct Theme {

  struct Main {
    static let colors = [
      UIColor(hex: "37F7BA").CGColor,
      UIColor(hex: "05ABBF").CGColor,
      UIColor(hex: "0C80C3").CGColor
    ]
    static let locations = [0.05,0.5,0.95]
  }

  struct DarkColors {
    static let colors = [
      UIColor(hex: "00FFE4").CGColor,
      UIColor(hex: "483076").CGColor
    ]
    static let locations = [0.0,1.0]
  }

  struct HighContrast {
    static let colors = [
      UIColor(hex: "F7F7F7").CGColor,
      UIColor(hex: "D0D0D0").CGColor
    ]
    static let locations = [0.0,1.0]
  }

}
