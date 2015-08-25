import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {

  @IBOutlet weak var plate1Group: WKInterfaceGroup!
  @IBOutlet weak var plate2Group: WKInterfaceGroup!
  @IBOutlet weak var plate3Group: WKInterfaceGroup!
  @IBOutlet weak var plate4Group: WKInterfaceGroup!
  @IBOutlet weak var ovenGroup: WKInterfaceGroup!

  @IBOutlet weak var plate1Label: WKInterfaceLabel!
  @IBOutlet weak var plate2Label: WKInterfaceLabel!
  @IBOutlet weak var plate3Label: WKInterfaceLabel!
  @IBOutlet weak var plate4Label: WKInterfaceLabel!
  @IBOutlet weak var ovenLabel: WKInterfaceLabel!

  var plateGroups = [WKInterfaceGroup]()
  var plateLabels = [WKInterfaceLabel]()

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    plateGroups = [plate1Group, plate2Group, plate3Group, plate4Group, ovenGroup]
    plateLabels = [plate1Label, plate2Label, plate3Label, plate4Label, ovenLabel]
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
    WKInterfaceController.openParentApplication(["request": "getAlarms"]) {
      [unowned self] response, error in
      if let response = response,
        alarms = response["alarms"] as? [AnyObject] {
          for (index, alarm) in enumerate(alarms) {
            if let alarmData = alarm as? [String: AnyObject]
              where index < self.plateGroups.count {
                self.updatePlate(index, data: alarmData)
            }
          }
      } else {
        println("Error with fetching of alarms from the parent app")
      }
    }
  }

  // MARK: - UI

  func updatePlate(index: Int, data: [String: AnyObject]) {
    if let firedDate = data["firedDate"] as? NSDate,
      numberOfSeconds = data["numberOfSeconds"] as? NSNumber {
        let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
        let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
        let currentSecond = secondsLeft % 60
        var minutesLeft = floor(secondsLeft / 60)
        let hoursLeft = floor(minutesLeft / 60)

        if hoursLeft > 0 {
          minutesLeft = minutesLeft - (hoursLeft * 60)
        }

        let minutes = Int(minutesLeft)
        let hours = Int(hoursLeft)
        var text = "\(minutes)"

        if hours > 0 {
          if minutes < 10 {
            text = "\(hours):0\(minutes)"
          } else {
            text = "\(hours):\(minutes)"
          }
        }

        self.plateGroups[index].setBackgroundImageNamed("timerFrame")
        self.plateGroups[index].startAnimatingWithImagesInRange(NSRange(location: minutes, length: 1),
          duration: 0, repeatCount: 1)
        self.plateLabels[index].setText(text)
    }
  }
}
