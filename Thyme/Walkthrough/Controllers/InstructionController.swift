import UIKit

public class InstructionController: UIViewController {

  public var delegate: InstructionDelegate?

  let imageViewTopMargin: CGFloat = 50
  let titleLabelTopMargin: CGFloat = 240
  let titleLabelHeight: CGFloat = 60
  let textViewHorizontalMargin: CGFloat = 20
  let textViewHeight: CGFloat = 150
  let acceptButtonBottomMargin: CGFloat = 30
  let acceptButtonHorizontalMargin: CGFloat = 30
  let acceptButtonHeight: CGFloat = 44

  let image: UIImage?
  let message: String?
  let hasAction: Bool?
  let isWelcome: Bool?
  let index: NSInteger?

  var isHidden: Bool? = false
  var isFirst: Bool? = false
  var isLast: Bool? = false

  // MARK: Lazy loading

  lazy var titleLabelFrame: CGRect = {
    var y = self.titleLabelTopMargin

    if (Screen.height == 480 || Screen.height == 568) {
      if self.isWelcome == false { y -= 40 }
    } else if (Screen.height == 667) {
      y += 60
    } else if (Screen.height == 736) {
      y += 70
    }

    if self.isWelcome == false {
      y += 20
    }

    return CGRectMake(10, y, CGRectGetWidth(self.view.frame) - 20, self.titleLabelHeight)
    }()

  lazy var messageTextViewFrame: CGRect = {
    var y = self.titleLabelTopMargin + self.titleLabelHeight

    if (Screen.height == 480) {
      if self.isWelcome == false { y -= 50 }
    } else if (Screen.height == 667) {
      y += 60
    } else if (Screen.height == 736) {
      y += 80
    }

    if self.isWelcome == false {
      y += 20
    }

    return CGRectMake(self.textViewHorizontalMargin, y,
      CGRectGetWidth(self.view.frame) - self.textViewHorizontalMargin * 2,
      self.textViewHeight)
    }()

  lazy var acceptButtonFrame: CGRect = {
    var y = Screen.height - self.acceptButtonHeight - self.acceptButtonBottomMargin
    if self.isWelcome == false { y -= 15 }

    return CGRectMake(self.acceptButtonHorizontalMargin,  y,
      CGRectGetWidth(self.view.frame) - self.acceptButtonHorizontalMargin * 2,
      self.acceptButtonHeight)
    }()

  lazy var previousButtonFrame: CGRect = {
    return CGRectMake(10, 0, 80, 44)
    }()

  lazy var nextButtonFrame: CGRect = {
    var x = Screen.width - 80 - 10
    return CGRectMake(x, 0, 80, 44)
    }()

  lazy var iconImageView: UIImageView = {
    let imageView = UIImageView(image: self.image)
    var frame = imageView.frame

    if self.isWelcome == true || self.index == 0 {
      frame.origin.x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(imageView.frame)) / 2
      frame.origin.y = self.imageViewTopMargin
    } else {
      frame.origin.y = self.imageViewTopMargin

      if Screen.height == 480 {
        frame.origin.y -= 25
      }

      if self.index == 1 {
        frame.origin.y += 45
      } else {
        if Screen.height == 568 || Screen.height == 480 {
          frame.size.width = 640/4
          frame.size.height = 780/4
        } else if (Screen.height >= 667) {
          frame.size.width = 640/3
          frame.size.height = 780/3
        }
      }

      frame.origin.x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(frame)) / 2
    }

    imageView.frame = frame

    return imageView
    }()

  lazy var titleLabel: UILabel = {
    let label = UILabel(frame: self.titleLabelFrame)
    label.text = self.title
    label.font = Font.Instruction.title
    label.textColor = UIColor(hex: "0896A2")
    label.adjustsFontSizeToFitWidth = true

    return label
    }()

  lazy var messageTextView: UITextView = {
    let textView = UITextView(frame: self.messageTextViewFrame)
    textView.text = self.message
    textView.font = Font.Instruction.message
    textView.textColor = UIColor(hex: "0896A2")
    textView.textAlignment = .Center
    textView.backgroundColor = UIColor.clearColor()
    textView.editable = false

    return textView
    }()

  lazy var acceptButton: UIButton = {
    let button = UIButton(type: .Custom)
    button.backgroundColor = UIColor(hex: "FF5C5C")
    button.highlightedBackgroundColor = UIColor(hex: "E94F4F")
    button.layer.cornerRadius = 5
    button.frame = self.acceptButtonFrame
    button.titleLabel?.font = Font.Instruction.acceptButton
    button.setTitle(NSLocalizedString("InstructionAction", comment: ""), forState: .Normal)
    button.addTarget(self, action: "acceptButtonAction", forControlEvents: .TouchUpInside)
    return button
    }()

  lazy var previousButton: UIButton = {
    let button = UIButton(type: .Custom)
    button.frame = self.previousButtonFrame
    button.titleLabel?.font = Font.Instruction.previousButton
    button.setTitleColor(UIColor(hex: "FA5A58"), forState: .Normal)
    button.setTitle(NSLocalizedString("Previous", comment: ""), forState: .Normal)
    button.addTarget(self, action: "previousButtonAction", forControlEvents: .TouchUpInside)
    return button
    }()

  lazy var nextButton: UIButton = {
    let button = UIButton(type: .Custom)
    button.frame = self.nextButtonFrame
    button.titleLabel?.font = Font.Instruction.nextButton
    button.setTitleColor(UIColor(hex: "FA5A58"), forState: .Normal)
    button.setTitle(NSLocalizedString("Next", comment: ""), forState: .Normal)
    button.addTarget(self, action: "nextButtonAction", forControlEvents: .TouchUpInside)
    return button
    }()

  // MARK: Initializer

  init(image: UIImage, title: String, message: String, hasAction: Bool, isWelcome: Bool, index: NSInteger) {
    self.image = image
    self.message = message
    self.hasAction = hasAction
    self.isWelcome = isWelcome
    self.index = index

    super.init(nibName: nil, bundle: nil)
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  func acceptButtonAction() {
    LocalNotificationManager.registerUserNotificationSettings()
  }

  func nextButtonAction() {
    if let method = delegate?.instructionControllerDidTapNextButton {
      method(self)
    }
  }

  func previousButtonAction() {
    if let method = delegate?.instructionControllerDidTapPreviousButton {
      method(self)
    }
  }

  // MARK: - Public methods

  public func cancelledNotifications() {
    if isHidden == true { return }

    let instructionsPageViewController = InstructionsPageController(transitionStyle: .Scroll,
      navigationOrientation: .Horizontal,
      options: nil)

    navigationController?.pushViewController(instructionsPageViewController,
      animated: true)
  }
}

// MARK: - UIViewController

extension InstructionController {

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(hex: "EDFFFF")

    view.addSubview(iconImageView)
    view.addSubview(titleLabel)
    view.addSubview(messageTextView)

    if index > 0 {
      view.addSubview(previousButton)
    }

    if index >= 0 && index < 4 {
      view.addSubview(nextButton)
    }

    if hasAction == true {
      view.addSubview(acceptButton)
    }
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.setNeedsStatusBarAppearanceUpdate()
  }

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }

  public override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    isHidden = true
  }
}

@objc public protocol InstructionDelegate {
  optional func instructionControllerDidTapNextButton(controller: InstructionController)
  optional func instructionControllerDidTapPreviousButton(controller: InstructionController)
}
