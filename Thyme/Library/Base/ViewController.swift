import UIKit

protocol ContentSizeChangable {
    func contentSizeCategoryDidChange(_ notification: Notification)
}

class ViewController: UIViewController {
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)

        return layer
    }()

    var theme: Themable?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let theme = theme {
            return theme.statusbarStyle
        } else {
            return .lightContent
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = true
        view.autoresizesSubviews = true

        gradientLayer.bounds = view.bounds
    }

    func viewWillAppear(_ animated: Bool, addGradient: Bool = true) {
        super.viewWillAppear(animated)

        if addGradient { view.layer.insertSublayer(gradientLayer, at: 0) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension UIViewController {
    func addViewController(_ controller: UIViewController, inFrame frame: CGRect = CGRect.zero) {
        addChildViewController(controller)

        if !frame.isEmpty {
            controller.view.frame = frame
        }

        view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

    func removeViewController(_ controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }

    func transitionToViewController(_ controller: UIViewController, duration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
        controller.willMove(toParentViewController: nil)
        addChildViewController(self)

        transition(from: self,
                   to: controller,
                   duration: duration,
                   options: UIViewAnimationOptions.autoreverse,
                   animations: animations) { (finished) -> Void in
            self.removeFromParentViewController()
            controller.didMove(toParentViewController: self)
            completion?(finished)
        }
    }
}
