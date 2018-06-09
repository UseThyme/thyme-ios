import UIKit

public func arc4random<T: ExpressibleByIntegerLiteral>(_ type: T.Type) -> T {
    var r: T = 0
    arc4random_buf(&r, MemoryLayout<T>.size)
    return r
}

public extension Int {
    public static func random(_ lower: Int, upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

enum ImageType {
    case animated, background
}

enum HerbieMood {
    case happy, sad, neutral
}

struct Reason {
    var backgroundColor: UIColor
    var title: String
    var titleColor: UIColor
    var text: String
    var textColor: UIColor
    var imageName: String?
    var imageType: ImageType
    var tryText: String
    var tryTextColor: UIColor
    var tryBackground: UIColor = UIColor.white
    var reasonText: String
    var herbieMood: HerbieMood?

    init(backgroundColor: UIColor, title: String, titleColor: UIColor = UIColor(hex: "FF4963"), text: String, textColor: UIColor = UIColor(hex: "FF7A7A"), imageName: String? = nil, imageType: ImageType, tryText: String = "Let's give it another try!", tryTextColor: UIColor = UIColor.white, tryBackground: UIColor = UIColor.white, reasonText: String = "Give me a real reason", herbieMood: HerbieMood = .neutral) {
        self.backgroundColor = backgroundColor
        self.title = title
        self.titleColor = titleColor
        self.text = text
        self.textColor = textColor
        self.imageType = imageType
        self.imageName = imageName
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
            text: "Without notifications and sounds, we\nsimply can’t tell you when your lobster is ready! It might get rubbery :(",
            textColor: UIColor(hex: "FF5858"),
            imageName: "Lobster",
            imageType: .background,
            tryText: "Let’s give it another try!",
            tryTextColor: UIColor(hex: "FF5858"),
            tryBackground: UIColor.white,
            herbieMood: .neutral
        ))

        reasons.append(Reason(
            backgroundColor: UIColor(hex: "FFF3D2"),
            title: "That Thanksgiving\n turkey will be ruined",
            titleColor: UIColor(hex: "FF5858"),
            text: "Without notifications and sounds, we\nsimply can’t tell you when your turkey is ready! It might get burned :(",
            textColor: UIColor(hex: "FF5858"),
            imageName: "Turkey",
            imageType: .background,
            tryText: "Let’s give it another try!",
            tryTextColor: UIColor(hex: "FF5858"),
            tryBackground: UIColor.white,
            herbieMood: .neutral
        ))

        reasons.append(Reason(
            backgroundColor: UIColor(hex: "FFF3D2"),
            title: "Because bacon tastes\nbetter than charcoal",
            titleColor: UIColor(hex: "FF5858"),
            text: "Without notifications and sounds, we\nsimply can’t tell you when your bacon is ready! It might get burned :(",
            textColor: UIColor(hex: "FF5858"),
            imageName: "Bacon",
            imageType: .background,
            tryText: "Let’s give it another try!",
            tryTextColor: UIColor(hex: "FF5858"),
            tryBackground: UIColor.white,
            herbieMood: .neutral
        ))

        reasons.append(Reason(
            backgroundColor: UIColor(hex: "FFE8FC"),
            title: "That octopus is\ngonna get SO rubbery",
            titleColor: UIColor(hex: "FF5858"),
            text: "Without notifications and sounds, we\nsimply can’t tell you when your octopus is ready! Nobody likes rubbery octopus.",
            textColor: UIColor(hex: "FF5858"),
            imageName: "Octopus",
            imageType: .background,
            tryText: "Let’s give it another try!",
            tryTextColor: UIColor(hex: "FF5858"),
            tryBackground: UIColor.white,
            herbieMood: .neutral
        ))

        reasons.append(Reason(
            backgroundColor: UIColor(hex: "D7F5FF"),
            title: "Birthdays only\ncome once a year",
            titleColor: UIColor(hex: "FF5858"),
            text: "Without notifications and sounds, we\nsimply can’t tell you when the cake\nyou’ve spent all day on is done.\nMake it count!",
            textColor: UIColor(hex: "FF5858"),
            imageName: "Birthday",
            imageType: .background,
            tryText: "Let’s give it another try!",
            tryTextColor: UIColor(hex: "FF5858"),
            tryBackground: UIColor.white,
            herbieMood: .neutral
        ))

        reasons.append(Reason(
            backgroundColor: UIColor(hex: "D7F8AC"),
            title: "Because your plate\nneeds a friend",
            titleColor: UIColor(hex: "FF5858"),
            text: "Without notifications and sounds, we\nsimply can’t tell you when you can hang out with the plates again :(",
            textColor: UIColor(hex: "FF5858"),
            imageName: "Dinner",
            imageType: .background,
            tryText: "Let’s give it another try!",
            tryTextColor: UIColor(hex: "FF5858"),
            tryBackground: UIColor.white,
            herbieMood: .neutral
        ))

        return reasons
    }
}

class HerbieController: ViewController {
    override var theme: Themable? {
        willSet(newTheme) {
            gradientLayer.colors = [
                UIColor(hex: "E3FFFF").cgColor,
                UIColor(hex: "E3FFFF").cgColor,
            ]
            gradientLayer.locations = newTheme?.locations as! [NSNumber]
        }
    }

    var reason: Reason? {
        didSet {
            let height: CGFloat = 55
            let width: CGFloat = 295
            let bottomMargin: CGFloat = 18

            if reason?.imageName != nil {
                reasonImage.image = UIImage(named: reason!.imageName!)
                titleLabel.transform = CGAffineTransform(translationX: -1000, y: 0)
            }
            titleLabel.transform = CGAffineTransform(translationX: 1000, y: 0)
            textLabel.transform = CGAffineTransform(translationX: 1000, y: 0)

            UIView.animate(withDuration: 0.3, animations: {
                if let reason = self.reason {
                    self.gradientLayer.colors = [
                        reason.backgroundColor.cgColor,
                        reason.backgroundColor.cgColor,
                    ]
                    self.gradientLayer.locations = [0, 1]
                }

                if self.reason?.herbieMood == .neutral {
                    self.herbie.alpha = 0.0
                }
                self.titleLabel.transform = CGAffineTransform.identity
                self.textLabel.transform = CGAffineTransform.identity
                self.reasonImage.transform = CGAffineTransform.identity
                self.tryButton.setTitle(self.reason?.tryText, for: UIControlState())
                self.tryButton.setTitleColor(self.reason?.tryTextColor, for: UIControlState())
                self.tryButton.backgroundColor = self.reason?.tryBackground

                self.tryButton.layer.cornerRadius = height / 2
                self.titleLabel.text = self.reason?.title
                self.titleLabel.textColor = self.reason?.titleColor

                self.textLabel.text = self.reason?.text
                self.textLabel.textColor = self.reason?.textColor

                self.reasonButton.setTitle("Give me another reason", for: UIControlState())
                self.reasonButton.setTitleColor(self.reason?.tryTextColor, for: UIControlState())
                self.reasonButton.backgroundColor = self.reason?.tryBackground
                self.reasonButton.layer.cornerRadius = height / 2

                if self.reason?.herbieMood == .happy {
                } else if self.reason?.herbieMood == .sad {
                    self.reasonButton.alpha = 1.0
                    self.reasonImage.alpha = 0.0
                } else {
                    self.herbie.alpha = 0.0
                    self.reasonImage.alpha = 1.0
                }

                if self.reason?.imageType == .animated && self.reason?.herbieMood == .happy {
                    var images = [UIImage]()
                    for x in 0 ... 23 {
                        images.append(UIImage(named: "HappyHerbie_\(x)")!)
                    }
                    self.herbie.animationImages = images
                    self.herbie.startAnimating()
                    self.herbie.alpha = 1.0
                } else if self.reason?.imageType == .animated && self.reason?.herbieMood == .sad {
                    var frame = self.herbie.frame
                    frame.size.height = 225
                    self.herbie.frame = frame
                    var images = [UIImage]()
                    for x in 0 ... 39 {
                        images.append(UIImage(named: "SadHerbie_\(x)")!)
                    }
                    self.herbie.animationImages = images
                    self.herbie.startAnimating()
                    self.herbie.alpha = 1.0
                }
            }, completion: { _ in
                if self.reason?.herbieMood == .happy {
                    self.tryButton.frame = CGRect(
                        x: self.view.bounds.width / 2 - width / 2,
                        y: self.view.bounds.height - height - bottomMargin,
                        width: width, height: height)
                } else if self.reason?.herbieMood == .sad {
                    self.reasonButton.frame = CGRect(
                        x: self.view.bounds.width / 2 - width / 2,
                        y: self.view.bounds.height - height - bottomMargin,
                        width: width, height: height)

                    self.tryButton.frame = CGRect(
                        x: self.view.bounds.width / 2 - width / 2,
                        y: self.view.bounds.height - height - bottomMargin * 1.5 - height,
                        width: width, height: height)
                } else {
                    var frame = self.titleLabel.frame
                    frame.size.width = Screen.width
                    frame.size.height = 72 * 2
                    frame.origin.x = 0
                    frame.origin.y = Screen.height / 2 - frame.size.height / 2 - 17
                    self.titleLabel.frame = frame
                }
            })
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

    lazy var reasonImage: UIImageView = {
        let width: CGFloat = Screen.width
        var height: CGFloat = Screen.height - 300
        if height > 300 { height = 300 }

        let imageView = UIImageView(frame: CGRect(x: Screen.width / 2 - width / 2,
                                                  y: 0,
                                                  width: width, height: height))
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let height: CGFloat = 72
        let topOffset: CGFloat = -17
        let label = UILabel(frame: CGRect(x: 0, y: Screen.height / 2 - height / 2 + topOffset,
                                          width: Screen.width, height: height))
        label.font = Font.Herbie.title
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    lazy var textLabel: UILabel = { [unowned self] in
        let topOffset: CGFloat = 16
        let xOffset: CGFloat = 10
        let label = UILabel(frame: CGRect(x: xOffset, y: self.titleLabel.frame.origin.y + topOffset,
                                          width: Screen.width - xOffset * 2, height: 138 + self.titleLabel.frame.height))
        label.numberOfLines = 9
        label.textAlignment = .center
        return label
    }()

    lazy var tryButton: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(HerbieController.registerNotificationSettings), for: .touchUpInside)
        return button
    }()

    lazy var reasonButton: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(HerbieController.anotherReason), for: .touchUpInside)
        button.alpha = 0.0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        for subview in [herbie, titleLabel, textLabel, tryButton, reasonImage, reasonButton] as [Any] { view.addSubview(subview as! UIView) }

        reason = Reason(backgroundColor: UIColor(hex: "E3FFFF"), title: "Hello, I'm Herbie!",
                        text: "In order for me to help you keep track of all that delicious food, yum, I need you to let me notify you and make a sound when I'm finished counting.\n\nNever otherwise, I promise!",
                        textColor: UIColor(hex: "0896A2"),
                        imageType: .animated,
                        tryText: "Ok, got it!",
                        tryBackground: UIColor(hex: "04BAC0"), herbieMood: .happy)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gradientLayer.colors = [
            reason!.backgroundColor.cgColor,
            reason!.backgroundColor.cgColor,
        ]
        gradientLayer.locations = [0, 1]

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @objc func registerNotificationSettings() {
        let registredSettings = UIApplication.shared.currentUserNotificationSettings

        AlarmCenter.registerNotificationSettings()

        if !AlarmCenter.hasCorrectNotificationTypes && !registredSettings!.categories!.isEmpty {
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url)
        }
    }

    func cancelledNotifications() {
        reason = Reason(backgroundColor: UIColor(hex: "FF7A7A"), title: "What's that smell?",
                        titleColor: UIColor.white,
                        text: "Without notifications and sounds,\n I simply can’t tell you when your food is ready!\nWhat if it gets burned?",
                        textColor: UIColor.white,
                        imageType: .animated,
                        tryText: "Let’s give it another try!",
                        tryTextColor: UIColor(hex: "FF5858"),
                        tryBackground: UIColor.white, herbieMood: .sad)

        gradientLayer.colors = [
            reason!.backgroundColor.cgColor,
            reason!.backgroundColor.cgColor,
        ]

        gradientLayer.locations = [0, 1]
    }

    @objc func anotherReason() {
        let reasons = Reason.reasons()
        var newReason = reasons[Int.random(0, upper: reasons.count - 1)]
        while reason?.title == newReason.title {
            newReason = reasons[Int.random(0, upper: reasons.count - 1)]
        }

        reasonImage.transform = CGAffineTransform.identity
        titleLabel.transform = CGAffineTransform.identity
        textLabel.transform = CGAffineTransform.identity

        UIView.animate(withDuration: 0.3, animations: {
            self.reasonImage.transform = CGAffineTransform(translationX: 0, y: -1000)
            self.titleLabel.transform = CGAffineTransform(translationX: -1000, y: 0)
            self.textLabel.transform = CGAffineTransform(translationX: -1000, y: 0)
        }, completion: { _ in
            self.reason = newReason
        })
    }
}
