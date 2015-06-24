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

  let items: [RowData] = [
    RowData(title: "Alarm 1"),
    RowData(title: "Alarm 2")]

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    setUpTable()
  }

  override func willActivate() {
    super.willActivate()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - UI

  func setUpTable() {
    table.setNumberOfRows(items.count, withRowType: Constants.rowType)

    for (index, item) in enumerate(items) {
      if let row = table.rowControllerAtIndex(index) as? AlarmTableRow {
        row.label.setText(item.title)
      }
    }
  }
}
