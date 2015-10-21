import WatchKit

struct AppGroup {
  static let identifier = "group.no.hyper.thyme"
  static let optionalDirectory = "wormhole"
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {

  func applicationDidFinishLaunching() {}
}
