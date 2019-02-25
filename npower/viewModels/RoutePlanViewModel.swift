import Foundation
import RxSwift
import RxSwiftExt

protocol RoutePlanViewModelProtocol {
    var visits: Observable<[Visit]>! { get }
}

class RoutePlanViewModel: RoutePlanViewModelProtocol {

    private let url = URL(string: "https://npower.azurewebsites.net/api/routeplan")!
    private let delayScheduler = SerialDispatchQueueScheduler(qos: .utility)

    private let apiClient: ApiClientProtocol!
    var visits: Observable<[Visit]>!

    init(apiClient: ApiClientProtocol) {
        self.apiClient = apiClient
        self.visits =
                Observable
                        .deferred { [unowned self] in
                            self.apiClient.getAndDecodeJsonResponse(toType: RoutePlan.self, from: self.url, queryParameters: [:])
                        }
                        .map { rp in
                            rp.visits
                        }
                        .unwrap()
                        .retry(.exponentialDelayed(maxCount: 3, initial: 1.0, multiplier: 1.0), scheduler: delayScheduler)
                        .share()
    }

}
