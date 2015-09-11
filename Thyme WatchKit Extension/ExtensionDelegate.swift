import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, Sessionable {

  func applicationDidFinishLaunching() {
    activateSession()
  }
}
