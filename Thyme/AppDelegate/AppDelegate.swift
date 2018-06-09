import AVFoundation
import UIKit

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {
    lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.main.bounds)
    }()

    lazy var navigationController: UINavigationController = { [unowned self] in
        let navigationController = UINavigationController(rootViewController: self.homeController)
        navigationController.isNavigationBarHidden = true

        return navigationController
    }()

    lazy var audioSession: AVAudioSession? = {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession
    }()

    lazy var audioPlayer: AVAudioPlayer? = {
        var error: NSError?

        let path = Bundle.main.path(forResource: "alarm", ofType: "caf")
        let file = URL(fileURLWithPath: path!)
        var audioPlayer: AVAudioPlayer?
        do { try audioPlayer = AVAudioPlayer(contentsOf: file) } catch { print("error loading sound") }

        return audioPlayer
    }()

    lazy var homeController: HomeViewController = {
        return HomeViewController()
    }()

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if UnitTesting.isRunning { return true }

        application.beginReceivingRemoteControlEvents()

        CustomAppearance.apply()

        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            handleLocalNotification(notification, playingSound: false)
        }

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        WatchCommunicator.sharedInstance.configureRoutes()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        homeController.theme = Theme.current()
        homeController.setNeedsStatusBarAppearanceUpdate()

        if !AlarmCenter.hasCorrectNotificationTypes() {
            if !homeController.herbieController.isBeingPresented {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    if !AlarmCenter.hasCorrectNotificationTypes() {
                        self.homeController.presentHerbie()
                    }
                })
            } else {
                homeController.cancelledNotifications()
            }
        } else {
            homeController.registeredForNotifications()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        application.beginBackgroundTask(expirationHandler: {})
        application.beginReceivingRemoteControlEvents()
    }

    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "appWasShaked"), object: nil)
        }
    }
}

// MARK: - Local Notifications

@available(iOS 9.0, *)
extension AppDelegate {
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if AlarmCenter.notificationsSettings().types != UIApplication.shared.currentUserNotificationSettings?.types {
            homeController.cancelledNotifications()
        } else {
            homeController.registeredForNotifications()
        }
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if UIApplication.shared.applicationState == .active {
            handleLocalNotification(notification, playingSound: true)
        }
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        AlarmCenter.handleNotification(notification, actionID: identifier)
        if let audioPlayer = self.audioPlayer, audioPlayer.isPlaying {
            self.audioPlayer!.stop()
            do { try audioSession?.setActive(false) } catch {}
        }

        completionHandler()
    }

    // MARK: - Private methods

    func handleLocalNotification(_ notification: UILocalNotification, playingSound: Bool) {
        if let userInfo = notification.userInfo, let _ = userInfo[Alarm.idKey] as? String {
            if playingSound {
                do { try audioSession?.setCategory(AVAudioSessionCategoryPlayback) } catch {}
                do { try audioSession?.setActive(true) } catch {}
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
            }

            let alert = UIAlertController(title: "Thyme", message: notification.alertBody, preferredStyle: .alert)
            let actionAndDismiss = { (action: String?) -> ((UIAlertAction) -> Void) in
                return { _ in
                    AlarmCenter.handleNotification(notification, actionID: action)
                    if let audioPlayer = self.audioPlayer, audioPlayer.isPlaying {
                        self.audioPlayer!.stop()
                    }
                }
            }

            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel, handler: actionAndDismiss(nil)))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add 3 mins", comment: ""),
                                          style: .default, handler: actionAndDismiss(AlarmCenter.Action.AddThreeMinutes.rawValue)))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add 5 mins", comment: ""),
                                          style: .default, handler: actionAndDismiss(AlarmCenter.Action.AddFiveMinutes.rawValue)))

            navigationController.visibleViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
