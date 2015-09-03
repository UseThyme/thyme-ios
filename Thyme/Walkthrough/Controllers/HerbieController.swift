import UIKit

enum ImageType {
  case Animated, Background
}

enum HerbieMood {
  case Happy, Sad, Neutral
}

struct Reason {
  var title: String
  var titleColor: UIColor
  var text: String
  var textColor: UIColor
  var imageType: ImageType
  var tryText: String
  var tryBackground: UIColor = UIColor.whiteColor()
  var reasonText: String
  var herbieMood: HerbieMood?

  init(title: String, titleColor: UIColor = UIColor(hex: "FF4963"), text: String, textColor: UIColor, imageType: ImageType, tryText: String = "Let's give it another try!", tryBackground: UIColor = UIColor.whiteColor(), reasonText: String = "Give me a real reason", herbieMood: HerbieMood = .Neutral) {
    self.title = title
    self.titleColor = titleColor
    self.text = text
    self.textColor = textColor
    self.imageType = imageType
    self.tryText = tryText
    self.tryBackground = tryBackground
    self.reasonText = reasonText
    self.herbieMood = herbieMood
  }
}

class HerbieController: ViewController {

  var reason: Reason? {
    didSet {
      let height: CGFloat = 55
      let width: CGFloat = 295
      let bottomMargin: CGFloat = 42
    
      tryButton.setTitle(reason?.tryText, forState: .Normal)
      tryButton.backgroundColor = reason?.tryBackground
      tryButton.frame = CGRect(
        x: view.bounds.width / 2 - width / 2,
        y: view.bounds.height - height - bottomMargin,
        width: width, height: height)
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
      }
    }
  }

  lazy var herbie: UIImageView = {
    let width: CGFloat = 160
    let height: CGFloat = 214
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

  lazy var tryButton: UIButton = {
    let button = UIButton(type: .Custom)
    return button
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(hex: "E3FFFF")

    for subview in [herbie, titleLabel, textLabel, tryButton] { view.addSubview(subview) }

    reason = Reason(title: "Hello, I'm Herbie!",
      text: "In order for me to help you keep track of\nall that delicious food, yum, I need you to\nlet me notify you and make a sound when\nI'm finished counting.\n\nNever otherwise, I promise!",
      textColor: UIColor(hex: "0896A2"),
      imageType: .Animated,
      tryText: "Ok, got it!",
      tryBackground: UIColor(hex: "04BAC0"), herbieMood: .Happy)
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .Default
  }

  func cancelledNotifications() {
    
  }

}
