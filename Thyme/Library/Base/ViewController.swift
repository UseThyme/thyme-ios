import UIKit

protocol ContentSizeChangable {
  func contentSizeCategoryDidChange(notification: NSNotification);
}

class ViewController: UIViewController {

  lazy var gradientLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)

    return layer
    }()

  var theme: Themable?

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    if let theme = theme {
      return theme.statusbarStyle
    } else {
      return .LightContent
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.userInteractionEnabled = true
    view.autoresizesSubviews = true

    gradientLayer.bounds = view.bounds
  }

  func viewWillAppear(animated: Bool, addGradient: Bool = true) {
    super.viewWillAppear(animated)

    if addGradient { view.layer.insertSublayer(gradientLayer, atIndex: 0) }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
}

extension UIViewController {

  func addViewController(controller: UIViewController, inFrame frame: CGRect = CGRectZero) {
    addChildViewController(controller)

    if !CGRectIsEmpty(frame) {
      controller.view.frame = frame
    }

    view.addSubview(controller.view)
    controller.didMoveToParentViewController(self)
  }

  func removeViewController(controller: UIViewController) {
    controller.willMoveToParentViewController(nil)
    controller.view.removeFromSuperview()
    controller.removeFromParentViewController()
  }

  func transitionToViewController(controller: UIViewController, duration: NSTimeInterval, animations: (() -> Void), completion: ((Bool) -> Void)?) {
    controller.willMoveToParentViewController(nil)
    addChildViewController(self)

    transitionFromViewController(self,
      toViewController: controller,
      duration: duration,
      options: UIViewAnimationOptions.Autoreverse,
      animations: animations) { (finished) -> Void in
        self.removeFromParentViewController()
        controller.didMoveToParentViewController(self)
        completion?(finished)
    }
  }
}
