import WatchKit
import Foundation



class HomeInterfaceController: WKInterfaceController {

  @IBOutlet weak var plate1MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var plate2MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var plate3MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var plate4MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var ovenMinutesGroup: WKInterfaceGroup!

  @IBOutlet weak var plate1SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var plate2SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var plate3SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var plate4SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var ovenSecondsGroup: WKInterfaceGroup!

  @IBOutlet weak var plate1Button: WKInterfaceButton!
  @IBOutlet weak var plate2Button: WKInterfaceButton!
  @IBOutlet weak var plate3Button: WKInterfaceButton!
  @IBOutlet weak var plate4Button: WKInterfaceButton!
  @IBOutlet weak var ovenButton: WKInterfaceButton!

  var plateMinutesGroups = [WKInterfaceGroup]()
  var plateSecondsGroups = [WKInterfaceGroup]()
  var plateButtons = [WKInterfaceButton]()

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    plateMinutesGroups = [plate1MinutesGroup, plate2MinutesGroup,
      plate3MinutesGroup, plate4MinutesGroup, ovenMinutesGroup]
    plateSecondsGroups = [plate1SecondsGroup, plate2SecondsGroup,
      plate3SecondsGroup, plate4SecondsGroup, ovenSecondsGroup]
    plateButtons = [plate1Button, plate2Button,
      plate3Button, plate4Button, ovenButton]
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
              where index < self.plateMinutesGroups.count {
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
        let seconds = 60 - Int(currentSecond)
        var text = "\(minutes)"

        if hours > 0 {
          if minutes < 10 {
            text = "\(hours):0\(minutes)"
          } else {
            text = "\(hours):\(minutes)"
          }
        }

        self.plateMinutesGroups[index].setBackgroundImageNamed(ImageList.Plate.minuteSequence)
        self.plateMinutesGroups[index].startAnimatingWithImagesInRange(
          NSRange(location: minutes, length: 1),
          duration: 0, repeatCount: 1)

        self.plateSecondsGroups[index].setBackgroundImageNamed(ImageList.Plate.secondSequence)
        self.plateSecondsGroups[index].startAnimatingWithImagesInRange(
          NSRange(location: seconds, length: 1),
          duration: 0, repeatCount: 1)

        self.plateButtons[index].setTitle(text)
    }
  }
}
