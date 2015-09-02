import UIKit

extension UIView {

  func toImage() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
    layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return capturedImage
  }
}
