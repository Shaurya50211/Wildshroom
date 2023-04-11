import Foundation
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    private var orientationLock = UIInterfaceOrientationMask.all

    func lockOrientationToPortrait() {
        if #available(iOS 16, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
        orientationLock = .portrait
    }

    func unlockOrientation() {
        orientationLock = .all
        setNeedsUpdateOfSupportedInterfaceOrientations()
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    private func setNeedsUpdateOfSupportedInterfaceOrientations() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                if let rootViewController = window.rootViewController {
                    rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
    }
}
