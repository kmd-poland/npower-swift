import UIKit
import Dip
import PromiseKit
import Mapbox
protocol LoginCoordinatorProtocol {
    func logIn() -> Promise<Void>
}

class MainCoordinator: Coordinator, LoginCoordinatorProtocol {
    let container: DependencyContainer!
    let authenticationService: AuthenticationServiceProtocol!
    let apiClientService: ApiClientProtocol!
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController,
         container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
        self.authenticationService = try! container.resolve() as AuthenticationServiceProtocol
        self.apiClientService = try! container.resolve() as ApiClientProtocol

    }

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        if (!authenticationService.isUserLoggedIn()) {
            let vc = LoginViewController()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: false)

        } else {
            showRoutePlan()
        }
    }

    private func showRoutePlan() {

        let viewModel = try! RoutePlanViewModel(apiClient: container.resolve())

        let vc = try! RoutePlanViewController(container.resolve())
        _ = vc.view

        let routePlanList = try! RoutePlanListViewController(container.resolve())

        vc.viewModel = viewModel
        routePlanList.viewModel = viewModel

        vc.panelController?.set(contentViewController: routePlanList)
        vc.panelController?.track(scrollView: routePlanList.tableView)

        navigationController.pushViewController(vc, animated: false)
    }

    func logIn() -> Promise<Void> {
        return authenticationService
                .getAuthTokenWithWebLogin()
                .done { [unowned self] _ in
                    self.navigationController.viewControllers = []
                    self.showRoutePlan()
                }
    }
}
