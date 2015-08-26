import WatchKit
import Foundation

class TimerInterfaceController: WKInterfaceController {

  @IBOutlet weak var minutesGroup: WKInterfaceGroup!
  @IBOutlet weak var secondsGroup: WKInterfaceGroup!
  @IBOutlet weak var minutesLabel: WKInterfaceLabel!
  @IBOutlet weak var textLabel: WKInterfaceLabel!

  var alarmTimer: AlarmTimer?

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
  }

  override func willActivate() {
    super.willActivate()
    //loadData()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }


}

// MARK: - AlarmTimerDelegate

extension HomeInterfaceController: AlarmTimerDelegate {


}
