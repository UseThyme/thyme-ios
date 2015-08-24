import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {

  @IBOutlet var plateGroups : [WKInterfaceGroup]!
  @IBOutlet var plateLabels : [WKInterfaceLabel]!

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
    WKInterfaceController.openParentApplication(["request": "getAlarms"]) {
      [unowned self] response, error in
      if let response = response,
        alarms = response["alarms"] as? [AnyObject] {
          for (index, alarm) in enumerate(alarms) {
            if let notification = alarm as? UILocalNotification,
              userinfo = notification.userInfo,
              firedDate = userinfo["HYPAlarmFireDate"] as? NSDate,
              numberOfSeconds = userinfo["HYPAlarmFireInterval"] as? NSNumber
              where index < self.plateGroups.count {
                let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
                let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
                let currentSecond = secondsLeft % 60
                var minutesLeft = floor(secondsLeft / 60)
                let hoursLeft = floor(minutesLeft / 60)

                if hoursLeft > 0 {
                  minutesLeft = minutesLeft - (hoursLeft * 60)
                }

                var text = "\(minutesLeft)"
                if hoursLeft > 0 {
                  if minutesLeft < 10 {
                    text = "\(hoursLeft):0\(minutesLeft)"
                  } else {
                    text = "\(hoursLeft):\(minutesLeft)"
                  }
                }

                self.plateGroups[index].setBackgroundImageNamed("timerFrame")
                self.plateGroups[index].startAnimatingWithImagesInRange(NSRange(location: Int(minutesLeft), length: 1),
                  duration: 0, repeatCount: 1)
                self.plateLabels[index].setText(text)
            }
          }
      } else {
        println("Error with fetching of alarms from the parent app")
      }
    }
  }
}
