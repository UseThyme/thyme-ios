import WatchKit
import Foundation
import WatchConnectivity

class Communicator: NSObject, WCSessionDelegate {

  typealias Completion = (response: [String: AnyObject]?, error: NSError?) -> Void

  var session: WCSession

  override init() {
    session = WCSession.defaultSession()
    super.init()

    session.delegate = self
    session.activateSession()
  }

  func sendMessage(message: Message, completion: Completion) {
    session.sendMessage(message.data, replyHandler: { response in
      completion(response: response, error: nil)
      }, errorHandler: { error in
        completion(response: nil, error: error)
    })
  }
}
