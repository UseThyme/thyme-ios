import WatchConnectivity

protocol Sessionable: WCSessionDelegate {
  var session : WCSession! { get set }
}

extension Sessionable {

  func activateSession() {
    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }
  }
}
