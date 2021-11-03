import AuthenticationServices
import SafariServices
import Flutter
import UIKit

public class SwiftFlutterWebAuthPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_web_auth", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterWebAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "authenticate" {
            let url = URL(string: (call.arguments as! Dictionary<String, AnyObject>)["url"] as! String)!
            let callbackURLScheme = (call.arguments as! Dictionary<String, AnyObject>)["callbackUrlScheme"] as! String
            let preferEphemeral = (call.arguments as! Dictionary<String, AnyObject>)["preferEphemeral"] as! Bool

            var sessionToKeepAlive: Any? = nil // if we do not keep the session alive, it will get closed immediately while showing the dialog
            let completionHandler = { (url: URL?, err: Error?) in
                sessionToKeepAlive = nil

                if let err = err {
                    if #available(iOS 12, *) {
                        if case ASWebAuthenticationSessionError.canceledLogin = err {
                            result(FlutterError(code: "CANCELED", message: "User canceled login", details: nil))
                            return
                        }
                    }

                    if #available(iOS 11, *) {
                        if case SFAuthenticationError.canceledLogin = err {
                            result(FlutterError(code: "CANCELED", message: "User canceled login", details: nil))
                            return
                        }
                    }

                    result(FlutterError(code: "EUNKNOWN", message: err.localizedDescription, details: nil))
                    return
                }

                result(url!.absoluteString)
            }

            if #available(iOS 12, *) {
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)

                if #available(iOS 13, *) {
                    guard let provider = UIApplication.shared.visibleViewController(FlutterViewController.self) else {
                        result(FlutterError(code: "FAILED", message: "Failed to aquire root FlutterViewController" , details: nil))
                        return
                    }

                    session.prefersEphemeralWebBrowserSession = preferEphemeral
                    session.presentationContextProvider = provider
                }

                session.start()
                sessionToKeepAlive = session
            } else if #available(iOS 11, *) {
                let session = SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
                session.start()
                sessionToKeepAlive = session
            } else {
                result(FlutterError(code: "FAILED", message: "This plugin does currently not support iOS lower than iOS 11" , details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

@available(iOS 13, *)
extension FlutterViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension UIApplication {
    
    /// Getting the VC in hierarchy by type.
    /// Supporting navigation, tab bar and presented controllers.
    func visibleViewController<Target: UIViewController>(_ target: Target.Type) -> Target? {
        let root = UIApplication.shared.windows.first?.rootViewController
        var visibleController: UIViewController?
        if let navigationRoot = root as? UINavigationController {
            visibleController = navigationRoot.topViewController
        } else if let tabRoot = root as? UITabBarController {
            visibleController = tabRoot.selectedViewController
        } else {
            // Common UIViewController
            visibleController = root
        }
        if let modalController = visibleController?.presentedViewController as? Target {
            return modalController
        } else {
            // If target not found as modal and the type cast below fails,
            // the target controller is not presented in hierarchy.
            return visibleController as? Target
        }
    }
}
