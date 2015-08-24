import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {

  @IBOutlet weak var plate1Group: WKInterfaceGroup!
  @IBOutlet weak var plate1Label: WKInterfaceLabel!

  @IBOutlet weak var plate2Group: WKInterfaceGroup!
  @IBOutlet weak var plate2Label: WKInterfaceLabel!

  @IBOutlet weak var plate3Group: WKInterfaceGroup!
  @IBOutlet weak var plate3Label: WKInterfaceLabel!

  @IBOutlet weak var plate4Group: WKInterfaceGroup!
  @IBOutlet weak var plate4Label: WKInterfaceLabel!

  @IBOutlet weak var ovenGroup: WKInterfaceGroup!
  @IBOutlet weak var ovenLabel: WKInterfaceLabel!

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


    //topLeftPlate.setBackgroundImageNamed("timerFrame")
    //topLeftPlate.startAnimatingWithImagesInRange(NSRange(location: 21, length: 1), duration: 0, repeatCount: 1)

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
