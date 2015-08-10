import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

  @IBOutlet weak var imageGroup: WKInterfaceGroup!

  @IBOutlet weak var subtitleLabel: WKInterfaceLabel!
  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
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
    WKInterfaceController.openParentApplication(["request": "getMaxMinutesLeft"]) {
      [unowned self] response, error in
      if let response = response,
        title = response["title"] as? String,
        subtitle = response["subtitle"] as? String {
          self.titleLabel.setText(title)
          self.subtitleLabel.setText(subtitle)
      } else {
        println("Error with fetching of info from the parent app")
      }
    }
  }
}
