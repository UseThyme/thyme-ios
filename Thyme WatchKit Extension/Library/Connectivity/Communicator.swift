import WatchKit
import Foundation
import WatchConnectivity

protocol CommunicatorDelegate: class {
  func communicatorDidReceiveApplicationContext(context: [String : AnyObject])
}

class Communicator: NSObject, WCSessionDelegate {

  typealias Completion = (response: [String : AnyObject]?, error: NSError?) -> Void

  var session: WCSession
  weak var delegate: CommunicatorDelegate?

  init(_ delegate: CommunicatorDelegate? = nil) {
    session = WCSession.defaultSession()
    super.init()

    self.delegate = delegate
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

  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    delegate?.communicatorDidReceiveApplicationContext(applicationContext)
  }
}
