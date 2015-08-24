import UIKit

@objc public class ViewController: UIViewController {

  lazy var gradientLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    layer.colors = Theme.Main.colors
    layer.locations = Theme.Main.locations

    return layer
    }()

  public override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.userInteractionEnabled = true
    view.autoresizesSubviews = true

    gradientLayer.bounds = view.bounds
    view.layer.addSublayer(gradientLayer)
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "changeBackground:",
      name: "changeBackground",
      object: nil)
  }

  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func changeBackground(notification: NSNotification) {
    if let userinfo = notification.userInfo,
      from = userinfo["from"] as? String,
      to = userinfo["to"] as? String {
        gradientLayer.colors = [
          UIColor(fromHex: from).CGColor,
          UIColor(fromHex: to).CGColor
        ]
    }
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
