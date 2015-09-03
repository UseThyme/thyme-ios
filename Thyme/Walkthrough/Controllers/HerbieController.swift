import UIKit

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

  static func reasons() {

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

      if reason?.herbieMood == .Happy {
        tryButton.frame = CGRect(
          x: view.bounds.width / 2 - width / 2,
          y: view.bounds.height - height - bottomMargin,
          width: width, height: height)
      } else {
        reasonButton.alpha = 1.0
        reasonButton.frame = tryButton.frame

        reasonButton.setTitle("Give me another reason", forState: .Normal)
        reasonButton.setTitleColor(reason?.tryTextColor, forState: .Normal)
        reasonButton.backgroundColor = reason?.tryBackground
        reasonButton.layer.cornerRadius = height / 2

        tryButton.frame = CGRect(
          x: view.bounds.width / 2 - width / 2,
          y: view.bounds.height - height - bottomMargin * 1.5 - reasonButton.frame.height,
          width: width, height: height)
      }

      tryButton.layer.cornerRadius = height / 2

      titleLabel.text = reason?.title
      titleLabel.textColor = reason?.titleColor

      textLabel.text = reason?.text
      textLabel.textColor = reason?.textColor

      if reason?.imageType == .Animated && reason?.herbieMood == .Happy {
        var images = [UIImage]()
        for x in 0...23 {
          images.append(UIImage(named: "HappyHerbie_\(x)")!)
        }
        herbie.animationImages = images
        herbie.startAnimating()
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

  }

}
