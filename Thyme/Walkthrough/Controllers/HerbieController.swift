import UIKit

public func arc4random <T: IntegerLiteralConvertible> (type: T.Type) -> T {

  var r: T = 0
  arc4random_buf(&r, sizeof(T))
  return r
}
public extension Int {

  public static func random (lower: Int , upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
  }
}

enum ImageType {
  case Animated, Background
}

enum HerbieMood {
  case Happy, Sad, Neutral
}

struct Reason {
  var backgroundColor: UIColor
  var title: String
  var titleColor: UIColor
  var text: String
  var textColor: UIColor
  var imageType: ImageType
  var tryText: String
  var tryTextColor: UIColor
  var tryBackground: UIColor = UIColor.whiteColor()
  var reasonText: String
  var herbieMood: HerbieMood?

  init(backgroundColor: UIColor, title: String, titleColor: UIColor = UIColor(hex: "FF4963"), text: String, textColor: UIColor = UIColor(hex: "FF7A7A"), imageType: ImageType, tryText: String = "Let's give it another try!", tryTextColor: UIColor = UIColor.whiteColor(), tryBackground: UIColor = UIColor.whiteColor(), reasonText: String = "Give me a real reason", herbieMood: HerbieMood = .Neutral) {
    self.backgroundColor = backgroundColor
    self.title = title
    self.titleColor = titleColor
    self.text = text
    self.textColor = textColor
    self.imageType = imageType
    self.tryText = tryText
    self.tryTextColor = tryTextColor
    self.tryBackground = tryBackground
    self.reasonText = reasonText
    self.herbieMood = herbieMood
  }

  static func reasons() -> [Reason] {
    var reasons = [Reason]()

    reasons.append(Reason(
      backgroundColor: UIColor(hex: "FFDBDB"),
      title: "That lobster looks\nfrickin’ expensive",
      titleColor: UIColor(hex: "FF5858"),
      text: "Without notifications and sounds, we\nsimply can’t tell you when your lobster\nis ready! It might get rubbery :(",
      textColor: UIColor(hex: "FF5858"),
      imageType: .Background,
      tryText: "Let’s give it another try!",
      tryTextColor: UIColor(hex: "FF5858"),
      tryBackground: UIColor.whiteColor(),
      herbieMood: .Neutral
      ))

    reasons.append(Reason(
      backgroundColor: UIColor(hex: "FFF3D2"),
      title: "That Thanksgiving\n turkey will be ruined",
      titleColor: UIColor(hex: "FF5858"),
      text: "Without notifications and sounds, we\nsimply can’t tell you when your turkey is\nready! It might get burned :(",
      textColor: UIColor(hex: "FF5858"),
      imageType: .Background,
      tryText: "Let’s give it another try!",
      tryTextColor: UIColor(hex: "FF5858"),
      tryBackground: UIColor.whiteColor(),
      herbieMood: .Neutral
      ))

    reasons.append(Reason(
      backgroundColor: UIColor(hex: "FFF3D2"),
      title: "Because bacon tastes\nbetter than charcoal",
      titleColor: UIColor(hex: "FF5858"),
      text: "Without notifications and sounds, we\nsimply can’t tell you when your bacon is\nready! It might get burned :(",
      textColor: UIColor(hex: "FF5858"),
      imageType: .Background,
      tryText: "Let’s give it another try!",
      tryTextColor: UIColor(hex: "FF5858"),
      tryBackground: UIColor.whiteColor(),
      herbieMood: .Neutral
      ))

    reasons.append(Reason(
      backgroundColor: UIColor(hex: "FFE8FC"),
      title: "That octopus is\ngonna get SO rubbery",
      titleColor: UIColor(hex: "FF5858"),
      text: "Without notifications and sounds, we\nsimply can’t tell you when your octopus\nis ready! Nobody likes rubbery octopus.",
      textColor: UIColor(hex: "FF5858"),
      imageType: .Background,
      tryText: "Let’s give it another try!",
      tryTextColor: UIColor(hex: "FF5858"),
      tryBackground: UIColor.whiteColor(),
      herbieMood: .Neutral
      ))

    reasons.append(Reason(
      backgroundColor: UIColor(hex: "D7F5FF"),
      title: "Birthdays only\ncome once a year",
      titleColor: UIColor(hex: "FF5858"),
      text: "Without notifications and sounds, we\nsimply can’t tell you when the cake\nyou’ve spent all day on is done.\nMake it count!",
      textColor: UIColor(hex: "FF5858"),
      imageType: .Background,
      tryText: "Let’s give it another try!",
      tryTextColor: UIColor(hex: "FF5858"),
      tryBackground: UIColor.whiteColor(),
      herbieMood: .Neutral
      ))

    reasons.append(Reason(
      backgroundColor: UIColor(hex: "D7F8AC"),
      title: "Because your plate\nneeds a friend",
      titleColor: UIColor(hex: "FF5858"),
      text: "Without notifications and sounds, we\nsimply can’t tell you when you can hang\nout with the plates again :(",
      textColor: UIColor(hex: "FF5858"),
      imageType: .Background,
      tryText: "Let’s give it another try!",
      tryTextColor: UIColor(hex: "FF5858"),
      tryBackground: UIColor.whiteColor(),
      herbieMood: .Neutral
      ))

    return reasons
  }
}

class HerbieController: ViewController {

  var reason: Reason? {
    didSet {
      let height: CGFloat = 55
      let width: CGFloat = 295
      let bottomMargin: CGFloat = 42

      view.backgroundColor = reason?.backgroundColor
      tryButton.setTitle(reason?.tryText, forState: .Normal)
      tryButton.setTitleColor(reason?.tryTextColor, forState: .Normal)
      tryButton.backgroundColor = reason?.tryBackground
      
      tryButton.layer.cornerRadius = height / 2
      titleLabel.text = reason?.title
      titleLabel.textColor = reason?.titleColor

      textLabel.text = reason?.text
      textLabel.textColor = reason?.textColor

      if reason?.herbieMood == .Happy {
        tryButton.frame = CGRect(
          x: view.bounds.width / 2 - width / 2,
          y: view.bounds.height - height - bottomMargin,
          width: width, height: height)
      } else if reason?.herbieMood == .Sad {
        reasonButton.alpha = 1.0
        reasonButton.frame = CGRect(
          x: view.bounds.width / 2 - width / 2,
          y: view.bounds.height - height - bottomMargin,
          width: width, height: height)

        reasonButton.setTitle("Give me another reason", forState: .Normal)
        reasonButton.setTitleColor(reason?.tryTextColor, forState: .Normal)
        reasonButton.backgroundColor = reason?.tryBackground
        reasonButton.layer.cornerRadius = height / 2

        tryButton.frame = CGRect(
          x: view.bounds.width / 2 - width / 2,
          y: view.bounds.height - height - bottomMargin * 1.5 - height,
          width: width, height: height)
      } else {
        herbie.alpha = 0.0
        var frame = titleLabel.frame
        frame.size.width = Screen.width
        frame.size.height = 72 * 2
        frame.origin.x = 0
        frame.origin.y = Screen.height / 2 - frame.size.height / 2 - 17
        titleLabel.frame = frame
      }

      if reason?.imageType == .Animated && reason?.herbieMood == .Happy {
        var images = [UIImage]()
        for x in 0...23 {
          images.append(UIImage(named: "HappyHerbie_\(x)")!)
        }
        herbie.animationImages = images
        herbie.startAnimating()
        herbie.alpha = 1.0
      } else if reason?.imageType == .Animated && reason?.herbieMood == .Sad {
        var frame = herbie.frame
        frame.size.height = 225
        herbie.frame = frame
        var images = [UIImage]()
        for x in 0...39 {
          images.append(UIImage(named: "SadHerbie_\(x)")!)
        }
        herbie.animationImages = images
        herbie.startAnimating()
        herbie.alpha = 1.0
      }
    }
  }

  lazy var herbie: UIImageView = {
    let width: CGFloat = 150
    let height: CGFloat = 200
    let topOffset: CGFloat = -100
    let imageView = UIImageView(frame: CGRect(x: Screen.width / 2 - width / 2,
      y: Screen.height / 2 - height / 2 + topOffset,
      width: width, height: height))

    return imageView
    }()

  lazy var titleLabel: UILabel = {
    let height: CGFloat = 72
    let topOffset: CGFloat = -17
    let label = UILabel(frame: CGRect(x: 0, y: Screen.height / 2 - height / 2 + topOffset,
      width: Screen.width, height: height))
    label.font = Font.Herbie.title
    label.textAlignment = .Center
    label.numberOfLines = 2
    return label
    }()

  lazy var textLabel: UILabel = { [unowned self] in
    let topOffset: CGFloat = 16
    let label = UILabel(frame: CGRect(x: 0, y: self.titleLabel.frame.origin.y + topOffset,
      width: Screen.width, height: 138 + self.titleLabel.frame.height))
    label.numberOfLines = 6
    label.textAlignment = .Center
    return label
    }()

  lazy var tryButton: UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.addTarget(self, action: "registerNotificationSettings", forControlEvents: .TouchUpInside)
    return button
    }()

  lazy var reasonButton: UIButton = { [unowned self] in
    let button = UIButton(type: .Custom)
    button.addTarget(self, action: "anotherReason", forControlEvents: .TouchUpInside)
    button.alpha = 0.0
    return button
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(hex: "E3FFFF")

    for subview in [herbie, titleLabel, textLabel, tryButton, reasonButton] { view.addSubview(subview) }

    reason = Reason(backgroundColor: UIColor(hex: "E3FFFF"), title: "Hello, I'm Herbie!",
      text: "In order for me to help you keep track of\nall that delicious food, yum, I need you to\nlet me notify you and make a sound when\nI'm finished counting.\n\nNever otherwise, I promise!",
      textColor: UIColor(hex: "0896A2"),
      imageType: .Animated,
      tryText: "Ok, got it!",
      tryBackground: UIColor(hex: "04BAC0"), herbieMood: .Happy)
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .Default
  }

  func registerNotificationSettings() {
    AlarmCenter.registerNotificationSettings()

    let registredSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
    let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
    if registredSettings!.types != types {
      let url = NSURL(string:UIApplicationOpenSettingsURLString)!
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  func cancelledNotifications() {
    reason = Reason(backgroundColor: UIColor(hex: "FF7A7A"), title: "What's that smell?",
      titleColor: UIColor.whiteColor(),
      text: "Without notifications and sounds,\n I simply can’t tell you when your food is ready!\nWhat if it gets burned?",
      textColor: UIColor.whiteColor(),
      imageType: .Animated,
      tryText: "Let’s give it another try!",
      tryTextColor: UIColor(hex: "FF5858"),
      tryBackground: UIColor.whiteColor(), herbieMood: .Sad)
  }

  func anotherReason() {
    let reasons = Reason.reasons()
    var newReason = reasons[Int.random(0, upper: reasons.count - 1)]
    while reason?.title == newReason.title {
      newReason = reasons[Int.random(0, upper: reasons.count - 1)]
    }
    reason = newReason
  }

}
