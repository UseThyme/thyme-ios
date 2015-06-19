import Foundation

class Setting {

  var title: String?
  var action: () -> Void

  init(title: String, action: () -> Void) {
    self.title = title
    self.action = action
  }

}
