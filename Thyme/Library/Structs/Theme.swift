struct Theme {

  struct Main {
    static let colors = [
      UIColor(fromHex: "37F7BA").CGColor,
      UIColor(fromHex: "05ABBF").CGColor,
      UIColor(fromHex: "0C80C3").CGColor
    ]
    static let locations = [0.05,0.5,0.95]
  }

  struct DarkColors {
    static let colors = [
      UIColor(fromHex: "00FFE4").CGColor,
      UIColor(fromHex: "483076").CGColor
    ]
    static let locations = [0,1]
  }

  struct HighContrast {
    static let colors = [
      UIColor(fromHex: "F7F7F7").CGColor,
      UIColor(fromHex: "D0D0D0").CGColor
    ]
    static let locations = [0,1]
  }

}
