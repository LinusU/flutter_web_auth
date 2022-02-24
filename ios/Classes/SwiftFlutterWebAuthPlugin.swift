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
        if call.method == "authenticate",
           let arguments = call.arguments as? Dictionary<String, AnyObject>,
           let urlString = arguments["url"] as? String,
           let url = URL(string: urlString),
           let callbackURLScheme = arguments["callbackUrlScheme"] as? String,
           let preferEphemeral = arguments["preferEphemeral"] as? Bool
        {

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

                guard let url = url else {
                    result(FlutterError(code: "EUNKNOWN", message: "URL was null, but no error provided.", details: nil))
                    return
                }

                result(url.absoluteString)
            }

            if #available(iOS 12, *) {
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)

                if #available(iOS 13, *) {
                    guard var topController = UIApplication.shared.keyWindow?.rootViewController else {
                        result(FlutterError.aquireRootViewControllerFailed)
                        return
                    }

                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    if let nav = topController as? UINavigationController {
                        topController = nav.visibleViewController ?? topController
                    }

                    guard let contextProvider = topController as? ASWebAuthenticationPresentationContextProviding else {
                        result(FlutterError.aquireRootViewControllerFailed)
                        return
                    }
                    session.presentationContextProvider =  contextProvider
                    session.prefersEphemeralWebBrowserSession = preferEphemeral
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
        } else if (call.method == "cleanUpDanglingCalls") {
            // we do not keep track of old callbacks on iOS, so nothing to do here
            result(nil)
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

fileprivate extension FlutterError {
    static var aquireRootViewControllerFailed: FlutterError {
        return FlutterError(code: "AQUIRE_ROOT_VIEW_CONTROLLER_FAILED", message: "Failed to aquire root view controller" , details: nil)
    }
}
