struct Routes {
    struct Watch {
        static let glance = "watch:glance"
        static let home = "watch:home"
        static let timer = "watch:timer"
    }

    struct App {
        static let alarms = "app:alarms"
        static let cancelAlarms = "app:alarms:cancel"
        static let alarm = "app:alarm"
        static let cancelAlarm = "app:alarm:cancel"
        static let updateAlarm = "app:alarm:update"
    }
}
