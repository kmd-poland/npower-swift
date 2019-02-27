import Foundation
import CoreLocation
import UserNotifications
import UIKit

protocol GeoFencingProtocol {
    var coordinator: MainCoordinator? { get set}
    func setGeoFence(for visit: Visit)
}

class GeoFencingService: NSObject, GeoFencingProtocol, CLLocationManagerDelegate{
    
    weak var coordinator: MainCoordinator?
    private let locationManager = CLLocationManager()
    private let routePlanProvider: RoutePlanProviderProtocol
    
    init(routePlanProvider: RoutePlanProviderProtocol) {
        self.routePlanProvider = routePlanProvider
        super.init()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
    }
    
    func setGeoFence(for visit: Visit){
        // Make sure region monitoring is supported.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let center = CLLocationCoordinate2D(latitude: visit.coordinates[1], longitude: visit.coordinates[0])
            let identifier = visit.avatar ?? "none"
            // Register the region.
            let maxDistance = 100.0
            let region = CLCircularRegion(center: center,
                                          radius: maxDistance, identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            
            locationManager.startMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func handleEvent(for region: CLRegion!) {
        guard  let visit = self.routePlanProvider.getVisit(forUser: region.identifier) else {
            return
        }
        let message = "Approaching \(visit.firstName ?? "") \(visit.lastName ?? "")"
        
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            print("in app geofence activated")
        } else {
            // Otherwise present a local notification
          
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = message
            notificationContent.sound = UNNotificationSound.default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "location_change",
                                                content: notificationContent,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
}

