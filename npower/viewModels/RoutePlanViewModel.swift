import Foundation
import RxSwift
import RxSwiftExt
import MapboxDirections
import CoreLocation

protocol RoutePlanViewModelProtocol {
    var visits: Observable<[Visit]>! { get }
    var currentRoute: Observable<Route>! { get }
}

class RoutePlanViewModel: NSObject, RoutePlanViewModelProtocol, CLLocationManagerDelegate {

    private let url = URL(string: "https://npower.azurewebsites.net/api/routeplan")!
    private let directions: Directions!

    private let delayScheduler = SerialDispatchQueueScheduler(qos: .utility)
    private let locationManager: CLLocationManager!

    private let lastLocation = Variable<CLLocationCoordinate2D?>(nil)
    private let routePlanProvider: RoutePlanProviderProtocol!
    private let geofenceService: GeoFencingProtocol!
    
    var visits: Observable<[Visit]>!
    var currentRoute: Observable<Route>!

    init(routePlanProvider: RoutePlanProviderProtocol, directions: Directions, locationManager: CLLocationManager, geofenceService: GeoFencingProtocol) {

        self.routePlanProvider = routePlanProvider
        self.directions = directions
        self.locationManager = locationManager
        self.geofenceService = geofenceService
       
        super.init()

        initializeObservables()
        locationManager.delegate = self
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
        
    }

    private func initializeObservables() {
        self.visits =
                Observable
                        .deferred { [unowned self] in
                           self.routePlanProvider.routePlan
                        }
                        .retry(.exponentialDelayed(maxCount: 3, initial: 1.0, multiplier: 1.0), scheduler: delayScheduler)
                        .share()

        let visitForDirections =
                self
                        .visits
                        .map { visits in
                            visits.first
                        }
                        .unwrap()
                        .do(onNext: {[unowned self] visit in self.geofenceService.setGeoFence(for: visit)})
                        .map { visit in
                            CLLocationCoordinate2D(latitude: visit.coordinates[1], longitude: visit.coordinates[0])
                        }
        

        self.currentRoute =
                Observable.combineLatest(visitForDirections, lastLocation.asObservable().unwrap())
                        .flatMapLatest {
                            [unowned self] visit, location in
                            self.getDirections(from: location, to: visit)
                        }
    }

    func getDirections(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Observable<Route> {
        let waypoints = [
            Waypoint(coordinate: from, name: "Origin"),
            Waypoint(coordinate: to, name: "Visit")
        ]
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
        options.includesSteps = true


        return Observable<Route>.create { [unowned self] observer in
            let task = self.directions.calculate(options) { wp, route, err in
                if let route = route?.first {
                    observer.onNext(route)
                    observer.onCompleted()
                } else if let err = err {
                    observer.onError(err)
                } else {
                    observer.onCompleted()
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            self.lastLocation.value = lastLocation.coordinate
        }
    }
}
