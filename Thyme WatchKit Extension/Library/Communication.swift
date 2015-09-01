import WatchKit
import Foundation

struct Communication {

  enum Kind: String {
    case GetAlarms = "getAlarms"
    case CancelAlarms = "cancelAlarms"
    case GetAlarm = "getAlarm"
    case UpdateAlarmMinutes = "updateAlarmMinutes"
    case CancelAlarm = "cancelAlarm"
  }

  typealias Completion = (response: [NSObject : AnyObject]!, error: NSError!) -> Void

  static func request(kind: Kind, parameters: [NSObject : AnyObject] = [:],
    completion: Completion) {
      var requestParameters = parameters
      requestParameters["request"] = kind.rawValue

//      WKInterfaceController.openParentApplication(requestParameters) { response, error in
//        completion(response: response, error: error)
//      }
  }
}
