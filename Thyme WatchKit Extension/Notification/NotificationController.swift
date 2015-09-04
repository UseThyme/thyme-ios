import WatchKit
import Foundation

class NotificationController: WKUserNotificationInterfaceController {

  @IBOutlet var alertLabel: WKInterfaceLabel!

  override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
    alertLabel.setText(localNotification.alertBody)
    WKInterfaceDevice.currentDevice().playHaptic(.Notification)
    completionHandler(.Custom)
  }
}
