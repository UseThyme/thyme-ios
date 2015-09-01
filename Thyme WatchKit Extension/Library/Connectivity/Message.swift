import WatchKit
import Foundation
import WatchConnectivity

struct Message {

  enum Kind: String {
    case GetAlarms = "getAlarms"
    case CancelAlarms = "cancelAlarms"
    case GetAlarm = "getAlarm"
    case UpdateAlarmMinutes = "updateAlarmMinutes"
    case CancelAlarm = "cancelAlarm"
  }

  var kind: Kind
  var parameters: [String: AnyObject]

  var data: [String: AnyObject] {
    var data = parameters
    data["request"] = kind.rawValue

    return data
  }

  init(kind: Kind, parameters: [String: AnyObject] = [:]) {
    self.kind = kind
    self.parameters = parameters
  }
}
