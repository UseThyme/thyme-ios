import UIKit
import AVFoundation
import WatchConnectivity
import HockeySDK

let ThymeAlarmIDKey = "HYPAlarmID"
let ThymeAlarmFireDataKey = "HYPAlarmFireDate"
let ThymeAlarmFireInterval = "HYPAlarmFireInterval"

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BITHockeyManagerDelegate, UIAlertViewDelegate {

  lazy var window: UIWindow? = {
    return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()

  lazy var navigationController: UINavigationController = { [unowned self] in
    let navigationController = UINavigationController(rootViewController: self.homeController)
    navigationController.navigationBarHidden = true

    return navigationController
    }()

  lazy var audioPlayer: AVAudioPlayer? = {
    var error: NSError?

    let path = NSBundle.mainBundle().pathForResource("alarm", ofType: "caf")
    let file = NSURL(fileURLWithPath: path!)
    var audioPlayer: AVAudioPlayer? = nil
    do { try audioPlayer = AVAudioPlayer(contentsOfURL: file) } catch { print("error loading sound") }

    return audioPlayer
  }()

  lazy var homeController: HomeViewController = {
    var theme: Themable = Theme.Main()

    if UIAccessibilityDarkerSystemColorsEnabled() {
      theme = Theme.DarkColors()

      if UIAccessibilityIsReduceTransparencyEnabled() {
        theme = Theme.HighContrast()
      }
    }
    let controller = HomeViewController(theme: theme)
    return controller
    }()

  lazy var isUnitTesting: Bool = {
    let enviorment = NSProcessInfo.processInfo().environment

    if let injectBundlePath = enviorment["XCInjectBundle"]
      where injectBundlePath.hasSuffix("xctest") {
        return true
    }

    return false
    }()

  var session: WCSession!

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
    do { try audioSession.setCategory(AVAudioSessionCategoryPlayback) } catch {}
    do { try audioSession.setActive(true) } catch {}
    application.beginReceivingRemoteControlEvents()

    let pageControl = UIPageControl.appearance()
    pageControl.pageIndicatorTintColor = UIColor(hex: "D0E8E8")
    pageControl.currentPageIndicatorTintColor = UIColor(hex: "FF5C5C")
    pageControl.backgroundColor = UIColor(hex: "EDFFFF")

    if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
      handleLocalNotification(notification, playingSound: false)
    }

    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }

    window!.rootViewController = navigationController
    window!.makeKeyAndVisible()

    return true
  }

  func applicationDidBecomeActive(application: UIApplication) {
    var theme: Themable = Theme.Main()

    if UIAccessibilityDarkerSystemColorsEnabled() {
      theme = Theme.DarkColors()

      if UIAccessibilityIsReduceTransparencyEnabled() {
        theme = Theme.HighContrast()
      }
    }

    homeController.theme = theme
    homeController.setNeedsStatusBarAppearanceUpdate()
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
    let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
    if notificationSettings.types != types {
      homeController.cancelledNotifications()
    } else {
      homeController.registeredForNotifications()
    }
  }

  // MARK: UIAlertViewDelegate

  func alert(alertView: UIAlertView, clickedButtonAtIndex: NSInteger) {
    audioPlayer!.stop()
  }

  // MARK: Private methods

  func handleLocalNotification(notification: UILocalNotification, playingSound: Bool) {
    if let userInfo = notification.userInfo,
    alarmID = userInfo[ThymeAlarmIDKey] as? String {
      cleanUpLocalNotificationWithAlarmID(alarmID)

      if playingSound {
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
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

  override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if motion == .MotionShake {
      NSNotificationCenter.defaultCenter().postNotificationName("appWasShaked", object: nil)
    }
  }
}

// MARK: - WatchKit

@available(iOS 9.0, *)
extension AppDelegate: WCSessionDelegate {

  func session(session: WCSession, didReceiveMessage message: [String : AnyObject],
    replyHandler: ([String : AnyObject]) -> Void) {
      if let request = message["request"] as? String {
        replyHandler(WatchCommunicator.response(request, message))
      }
  }
}
