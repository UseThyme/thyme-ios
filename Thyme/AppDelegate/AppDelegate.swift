import UIKit
import AVFoundation

let ThymeAlarmIDKey = "HYPAlarmID"
let ThymeAlarmFireDataKey = "HYPAlarmFireDate"
let ThymeAlarmFireInterval = "HYPAlarmFireInterval"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BITHockeyManagerDelegate, UIAlertViewDelegate {

  lazy var window: UIWindow? = {
    return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()

  lazy var navigationController: UINavigationController = {
    let navigationController = UINavigationController(rootViewController: self.homeController)
    navigationController.navigationBarHidden = true

    return navigationController
    }()

  lazy var audioPlayer: AVAudioPlayer = {
    var error: NSError?

    let path = NSBundle.mainBundle().pathForResource("alarm", ofType: "caf")
    let file = NSURL(fileURLWithPath: path!)
    let audioPlayer = AVAudioPlayer(contentsOfURL: file, error: &error)

    if error != nil {
      println("error loading sound")
    }

    return audioPlayer
  }()

  lazy var homeController = {
    return HomeViewController()
    }()

  lazy var isUnitTesting: Bool = {
    let enviorment = NSProcessInfo.processInfo().environment

    if let injectBundlePath = enviorment["XCInjectBundle"] as? String
      where injectBundlePath.pathExtension == "xctest" {
        return true
    }

    return false
    }()

  // MARK: UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    #if DEBUG
      if isUnitTesting() { return true }
    #endif

    #if IS_PRE_RELEASE_VERSION
      BITHockeyManager.sharedHockeyManager().configureWithIdentifier("2cf664c4f20eed78d8ef3fe53f27fe3b", delegate: self)
      BITHockeyManager.sharedHockeyManager().startManager()
    #endif

    let audioSession = AVAudioSession.sharedInstance()
    audioSession.setCategory(AVAudioSessionCategoryPlayback, error: nil)
    audioSession.setActive(true, error: nil)
    application.beginReceivingRemoteControlEvents()

    let pageControl = UIPageControl.appearance()
    pageControl.pageIndicatorTintColor = UIColor(fromHex: "D0E8E8")
    pageControl.currentPageIndicatorTintColor = UIColor(fromHex: "FF5C5C")
    pageControl.backgroundColor = UIColor(fromHex: "EDFFFF")

    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)

    if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
      handleLocalNotification(notification, playingSound: false)
    }

    window!.rootViewController = navigationController
    window!.makeKeyAndVisible()

    return true
  }

  func applicationDidBecomeActive(application: UIApplication) {

    var colors = Theme.Main.colors
    var locations = Theme.Main.locations

    if UIAccessibilityDarkerSystemColorsEnabled() {
      colors = Theme.DarkColors.colors
      locations = Theme.DarkColors.locations
    }

    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.postNotificationName("changeBackground",
      object: nil,
      userInfo: [
        "colors"  : colors,
        "locations" : locations])
  }

  func applicationDidEnterBackground(application: UIApplication) {
    application.beginBackgroundTaskWithExpirationHandler {}
    application.beginReceivingRemoteControlEvents()
  }

  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    let state = UIApplication.sharedApplication().applicationState
    var playingSound = true

    if state == .Background || state == .Inactive {
      playingSound = false
    }

    handleLocalNotification(notification, playingSound: playingSound)
  }

  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    let types: UIUserNotificationType = .Alert | .Badge | .Sound
    if notificationSettings.types != types {
      homeController.cancelledNotifications()
    } else {
      homeController.registeredForNotifications()
    }
  }

  // MARK: UIAlertViewDelegate

  func alert(alertView: UIAlertView, clickedButtonAtIndex: NSInteger) {
    audioPlayer.stop()
  }

  // MARK: Private methods

  func handleLocalNotification(notification: UILocalNotification, playingSound: Bool) {
    if let userInfo = notification.userInfo,
    alarmID = userInfo[ThymeAlarmIDKey] as? String {
      cleanUpLocalNotificationWithAlarmID(alarmID)

      if playingSound {
        audioPlayer.prepareToPlay()
        audioPlayer.play()
      }

      UIAlertView(title: notification.alertBody,
        message: nil,
        delegate: self,
        cancelButtonTitle: "OK").show()
    }
  }

  func cleanUpLocalNotificationWithAlarmID(alarmID: String) {
    UIApplication.sharedApplication().applicationIconBadgeNumber = 1
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0

    if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarmID) {
      UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
  }

  override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
    if motion == .MotionShake {
      NSNotificationCenter.defaultCenter().postNotificationName("appWasShaked", object: nil)
    }
  }
}

// MARK: - WatchKit

extension AppDelegate {

  func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {

    if let userInfo = userInfo, request = userInfo["request"] as? String {
      var workaround: UIBackgroundTaskIdentifier?
      workaround = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
        UIApplication.sharedApplication().endBackgroundTask(workaround!)
      })

      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
        UIApplication.sharedApplication().endBackgroundTask(workaround!)
      })

      var realBackgroundTask: UIBackgroundTaskIdentifier?
      realBackgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
        reply(nil)
        UIApplication.sharedApplication().endBackgroundTask(realBackgroundTask!)
      })

      var response = [NSObject : AnyObject]()

      if request == "getAlarms" {
        var notifications = [String]()
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification] {
          notifications.append(notification.alertBody!)
        }

        response = ["alarms": notifications]
      } else if request == "getMaxMinutesLeft" {
        response = [
          "title": homeController.titleLabel.text!,
          "subtitle": homeController.subtitleLabel.text!
        ]
      } else if request == "getPlate" {
        if let index = userInfo["index"] as? Int {
          response = homeController.plateDataForIndex(index)
        }
      }
      reply(response)

      UIApplication.sharedApplication().endBackgroundTask(realBackgroundTask!)
    }
  }
}
