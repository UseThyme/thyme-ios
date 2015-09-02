import UIKit

class SettingsViewController: UITableViewController {

  lazy var data: NSMutableArray = {
    var data = NSMutableArray()
    var sounds = NSMutableArray()
    var themes = NSMutableArray()

    themes.addObject( Setting(title: "Thyme", action: {
      let colorOptions = ["from":"3bf5e6", "to": "00979b", "textColor" : "30cec6", "duration" : 0.5]
      NSNotificationCenter.defaultCenter().postNotificationName("changeBackground", object: nil, userInfo: colorOptions)
    }))
    themes.addObject( Setting(title: "Swift", action: {
      let colorOptions = ["from":"F32E23", "to": "F3862E", "textColor" : "FFD200", "duration" : 0.5]
      NSNotificationCenter.defaultCenter().postNotificationName("changeBackground", object: nil, userInfo: colorOptions)
    }))
    themes.addObject( Setting(title: "Form", action: {
      let colorOptions = ["from":"32E0D5", "to": "5C2B9A", "textColor" : "5C2B9A", "duration" : 0.5]
      NSNotificationCenter.defaultCenter().postNotificationName("changeBackground", object: nil, userInfo: colorOptions)
    }))

    data.addObject(["title": "Themes", "items": themes])

    return data
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    let backgroundImageView = UIImageView(image: UIImage(named: "sc"))
    tableView.backgroundView = backgroundImageView
    tableView.separatorStyle = .None

    tableView.registerClass(SettingTableViewCell.classForCoder(),
      forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
    tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)
  }

}

// MARK: - UITableViewDataSource

extension SettingsViewController {

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return data.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let section = data[section] as? [String : AnyObject],
      items = section["items"] as? [Setting] {
      return items.count
    }
    return 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(SettingTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! SettingTableViewCell

    configure(cell, indexPath: indexPath)

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let section: AnyObject = data[indexPath.section]
    if let items = section["items"] as? [AnyObject],
      setting = items[indexPath.row] as? Setting {
        let method = setting.action
        method()
    }
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 35
  }

  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let section: AnyObject = data[section]
    let title = section["title"] as? String
    let label = UILabel(frame: CGRectMake(0,0,0,0))

    label.text = "   \(title!)"
    label.font = Font.Settings.headerLabel
    label.textColor = UIColor(hex: "EE4A64")
    label.backgroundColor = UIColor.clearColor()

    return label
  }

  func configure(cell: SettingTableViewCell, indexPath: NSIndexPath) {
    let section: AnyObject = data[indexPath.section]
    if let items = section["items"] as? [AnyObject],
      setting = items[indexPath.row] as? Setting {
        cell.setting = setting
    }
  }

}
