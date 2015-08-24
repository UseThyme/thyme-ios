import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {

  static var isFirst = true

  var index: Int = 0

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    if let index = context as? Int {
      self.index = index
    }

    loadData()
  }

  override func willActivate() {
    super.willActivate()
    if InterfaceController.isFirst {
      WKInterfaceController.reloadRootControllersWithNames(
        ["plateController", "plateController", "plateController", "plateController", "plateController"],
        contexts: [0, 1, 2, 3, 4])
      InterfaceController.isFirst = false
    }
    
    loadData()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Data

  func loadData() {
    WKInterfaceController.openParentApplication(["request": "getPlate", "index": index]) {
      [unowned self] response, error in
      if let response = response,
        title = response["title"] as? String,
        imageData = response["imageData"] as? NSData {
          let image = UIImage(data: imageData)
          
          self.titleLabel.setText(title)
          self.imageInterface.setImage(image)
      } else {
        println("Error with fetching of alarms from the parent app")
      }
    }
  }
}
