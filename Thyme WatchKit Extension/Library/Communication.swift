import WatchKit
import Foundation
import WatchConnectivity

class Communicator: NSObject, WCSessionDelegate {

  enum Kind: String {
    case GetAlarms = "getAlarms"
    case CancelAlarms = "cancelAlarms"
    case GetAlarm = "getAlarm"
    case UpdateAlarmMinutes = "updateAlarmMinutes"
    case CancelAlarm = "cancelAlarm"
  }

  typealias Completion = (response: [String: AnyObject]?, error: NSError?) -> Void

  var session: WCSession

  override init() {
    session = WCSession.defaultSession()
    super.init()

    session.delegate = self
    session.activateSession()
  }

  func sendMessage(kind: Kind, parameters: [String: AnyObject] = [:],
    completion: Completion) {
      var message = parameters
      message["request"] = kind.rawValue

      session.sendMessage(message, replyHandler: { response in
        completion(response: response, error: nil)
        }, errorHandler: { error in
          completion(response: nil, error: error)
      })
  }
}
