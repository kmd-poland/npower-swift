import Foundation
import RxSwift
import RxSwiftExt

protocol RoutePlanProviderProtocol {
    
    var routePlan: Observable<[Visit]>! { get }
    func getVisit(forUser: String) -> Visit?
}


class RoutePlanProviderService: RoutePlanProviderProtocol {
    private let url = URL(string: "https://npower.azurewebsites.net/api/routeplan")!
    private let apiClient: ApiClientProtocol!
    var routePlan: Observable<[Visit]>!
    
    init(apiClient: ApiClientProtocol) {
        self.apiClient = apiClient
        self.routePlan =
            self.apiClient.getAndDecodeJsonResponse(toType: RoutePlan.self, from: self.url, queryParameters: ["seed": "1223"])
                .map { rp in
                    rp.visits
                }
                .unwrap()
                .do(onNext: {[unowned self] visits in
                    self.storeVisits(visits)
                })
    }
    
    func getVisit(forUser: String) -> Visit? {
        if let visits =  getStoredVisits() {
            return visits.first(where: {$0.avatar == forUser})
        }
        return nil
    }
    
    
    private func storeVisits(_ visits: [Visit]){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(visits) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedVisits")
        }
    }
    
    private func getStoredVisits() -> [Visit]? {
        let defaults = UserDefaults.standard
        guard let savedVisits = defaults.object(forKey: "SavedVisits") as? Data  else {
            return nil
        }
        let decoder = JSONDecoder()
        if let loadedVisits = try? decoder.decode([Visit].self, from: savedVisits) {
            return loadedVisits
        }
        return nil
    }
    
}
