import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {

  @IBOutlet weak var topLeftPlate: WKInterfaceGroup!
  @IBOutlet weak var topRightPlate: WKInterfaceGroup!
  @IBOutlet weak var lowerLeftPlate: WKInterfaceGroup!
  @IBOutlet weak var lowerRightPlate: WKInterfaceGroup!

  @IBOutlet weak var topLeftPlateLabel: WKInterfaceLabel!
  @IBOutlet weak var topRightPlateLabel: WKInterfaceLabel!
  @IBOutlet weak var lowerLeftPlateLabel: WKInterfaceLabel!
  @IBOutlet weak var lowerRightPlateLabel: WKInterfaceLabel!

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    loadData()
  }

  override func willActivate() {
    super.willActivate()
    loadData()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Data

  func loadData() {
    topLeftPlate.setBackgroundImageNamed("timerFrame")
    topLeftPlate.startAnimatingWithImagesInRange(NSRange(location: 0, length: 21), duration: 0, repeatCount: 1)

    /*
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
    */
  }
}
