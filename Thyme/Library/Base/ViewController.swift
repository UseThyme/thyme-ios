import UIKit

@objc public class ViewController: UIViewController {

  lazy var gradientView: BKEAnimatedGradientView = {
    let gradientView = BKEAnimatedGradientView(frame: self.view.frame)

    let defaults = NSUserDefaults.standardUserDefaults()
    if let from = defaults.stringForKey("BackgroundColorFrom"),
      to = defaults.stringForKey("BackgroundColorTo") {
        gradientView.gradientColors = [UIColor(fromHex: from), UIColor(fromHex: to)]
    } else {
      gradientView.gradientColors = [
        UIColor(fromHex: "00F8C7"),
        UIColor(fromHex: "05ABBF"),
        UIColor(fromHex: "0C80C3")]
    }
    
    return gradientView
    }()

  public override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.userInteractionEnabled = true
    view.autoresizesSubviews = true
    view.addSubview(gradientView)
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

  public func changeGradient(from: UIColor, to: UIColor) {
    gradientView.gradientColors = [from, to]
  }

  public func animateChangeGradient(from: UIColor, to: UIColor, duration: CGFloat, delay: CGFloat = 0) {
    gradientView.changeGradientWithAnimation([from,to], delay: delay, duration: duration)
  }

  func changeBackground(notification: NSNotification) {
    if let userinfo = notification.userInfo {
      let from = userinfo["from"] as! String
      let to = userinfo["to"] as! String
      let textColor = userinfo["textColor"] as! String

      if let duration = userinfo["duration"] as? CGFloat {
        animateChangeGradient(UIColor(fromHex: from), to: UIColor(fromHex: to), duration: duration, delay: 0)
      } else {
        changeGradient(UIColor(fromHex: from), to: UIColor(fromHex: to))
      }

      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setValue(from, forKey: "BackgroundColorFrom")
      defaults.setValue(to, forKey: "BackgroundColorTo")
      defaults.setValue(textColor, forKey: "TextColor")
      defaults.synchronize()
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
