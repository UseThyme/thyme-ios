import UIKit

@objc public class ViewController: UIViewController {

  lazy var gradientView: BKEAnimatedGradientView = {
    let gradientView = BKEAnimatedGradientView(frame: self.view.frame)
    gradientView.gradientColors = [UIColor(fromHex: "3bf5e6"), UIColor(fromHex: "00979b")]
    return gradientView
    }()

  public override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.userInteractionEnabled = true
    view.addSubview(gradientView)
  }

}
