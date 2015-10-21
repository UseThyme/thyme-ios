struct Message {

  struct Inbox {
    static let UpdateAlarms = "Watch:updateAlarms"
    static let UpdateAlarm = "Watch:updateAlarm"
  }

  struct Outbox {
    static let FetchAlarms = "App:fetchAlarms"
    static let FetchAlarm = "App:fetchAlarm"
    static let CancelAlarm = "App:cancelAlarm"
    static let CancelAlarms = "App:cancelAlarms"
    static let UpdateAlarm = "App:updateAlarm"
  }
}
