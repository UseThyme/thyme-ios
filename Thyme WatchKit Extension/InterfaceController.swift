import WatchKit
import Foundation

struct RowData {
  let title: String
}

class InterfaceController: WKInterfaceController {

  struct Constants {
    static let rowType = "AlarmRowType"
  }

  @IBOutlet weak var table: WKInterfaceTable!

  var items: [String]?

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    loadTableData()
  }

  override func willActivate() {
    super.willActivate()
    loadTableData()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Data

  func loadTableData() {
    WKInterfaceController.openParentApplication(["request": "getAlarms"]) {
      [unowned self] response, error in
      if let response = response,
        alarms = response["alarms"] as? [String] {
          self.items = alarms
          self.setUpTable()
      } else {
        println("Error with fetching of alarms from the parent app")
      }
    }
  }

  // MARK: - UI

  func setUpTable() {
    if let items = items {
      table.setNumberOfRows(items.count, withRowType: Constants.rowType)

      for (index, item) in enumerate(items) {
        if let row = table.rowControllerAtIndex(index) as? AlarmTableRow {
          row.label.setText(item)
        }
      }
    }
  }
}
