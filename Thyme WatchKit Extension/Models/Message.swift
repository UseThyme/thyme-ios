import WatchKit
import Foundation
import WatchConnectivity

struct Message {

  enum Kind: String {
    case GetAlarms = "getAlarms"
    case CancelAlarms = "cancelAlarms"
    case GetAlarm = "getAlarm"
    case UpdateAlarm = "updateAlarm"
    case CancelAlarm = "cancelAlarm"
  }

  var kind: Kind
  var parameters: [String: AnyObject]

  var data: [String: AnyObject] {
    var data = parameters
    data["request"] = kind.rawValue

    return data
  }

  init(_ kind: Kind, _ parameters: [String: AnyObject] = [:]) {
    self.kind = kind
    self.parameters = parameters
  }
}
