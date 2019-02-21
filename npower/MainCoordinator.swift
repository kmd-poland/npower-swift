import UIKit
import PromiseKit

protocol LoginCoordinatorProtocol {
    func logIn() -> Promise<Void>
}

class MainCoordinator: Coordinator, LoginCoordinatorProtocol {
    let authenticationService: AuthenticationServiceProtocol!
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController, authenticationService: AuthenticationServiceProtocol) {
        self.navigationController = navigationController
        self.authenticationService = authenticationService
    }

    func start() {
        if (!authenticationService.isUserLoggedIn()) {
            let vc = LoginViewController()
            vc.coordinator = self
            navigationController.setNavigationBarHidden(true, animated: false)
            navigationController.pushViewController(vc, animated: false)

        } else {
            let vc = RoutePlanViewController()
            navigationController.pushViewController(vc, animated: false)
            navigationController.setNavigationBarHidden(false, animated: false)
        }
    }
    
    func logIn() -> Promise<Void> {
        return authenticationService
                .getAuthTokenWithWebLogin()
                .done{[unowned self] _ in
                    self.navigationController.viewControllers = [RoutePlanViewController()]
                    self.navigationController.setNavigationBarHidden(false, animated: false)

                }
    }
}
