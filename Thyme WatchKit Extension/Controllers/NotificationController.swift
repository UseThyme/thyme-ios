import Foundation
import WatchKit

class NotificationController: WKUserNotificationInterfaceController {
    @IBOutlet var alertLabel: WKInterfaceLabel!

    override func didReceive(_ localNotification: UILocalNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Void) {
        alertLabel.setText(localNotification.alertBody)
        WKInterfaceDevice.current().play(.notification)
        completionHandler(.custom)
    }
}
