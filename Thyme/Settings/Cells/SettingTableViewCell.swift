import UIKit

public class SettingTableViewCell: UITableViewCell {

  static let reuseIdentifier = "SettingTableViewCellIdentitifer"

  var setting: Setting? {
    willSet(newValue) {
      self.textLabel?.text = newValue?.title
    }
  }

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    backgroundColor = UIColor.clearColor()
    selectionStyle = .None
    textLabel?.font = HYPUtils.avenirBookWithSize(16)
    textLabel?.textColor = UIColor(fromHex: "B5B4B5")
  }

  public required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  public override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    textLabel?.textColor = selected == true
      ? UIColor(fromHex: "1C1A1C")
      : UIColor(fromHex: "B5B4B5")
  }
}
