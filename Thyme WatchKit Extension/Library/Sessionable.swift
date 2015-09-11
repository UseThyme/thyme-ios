import WatchConnectivity

protocol Sessionable: WCSessionDelegate { }

extension Sessionable {

  func activateSession() {
    if WCSession.isSupported() {
      let session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }
  }

  func sessionWatchStateDidChange(session: WCSession) {
    activateSession()
  }

  func sessionReachabilityDidChange(session: WCSession) {
    activateSession()
  }
}
