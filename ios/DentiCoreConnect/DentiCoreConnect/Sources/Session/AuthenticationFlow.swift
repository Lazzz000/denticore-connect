import UIKit

enum AuthenticationFlow {
    static func endSession(
        from viewController: UIViewController,
        animated: Bool = true
    ) {
        SessionManager.shared.clearSession()

        if let tabBarController = viewController.tabBarController,
           tabBarController.presentingViewController != nil {
            tabBarController.dismiss(animated: animated)
            return
        }

        viewController.navigationController?
            .popToRootViewController(animated: animated)
    }
}
