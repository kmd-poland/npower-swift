import UIKit

class MainCoordinator: Coordinator {
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
            navigationController.pushViewController(vc, animated: false)
        } else {
            let vc = RoutePlanViewController()
            navigationController.pushViewController(vc, animated: false)
        }
    }
}