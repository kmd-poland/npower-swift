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
    private let avatarProvider =  AvatarImageProvider()
    
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
    
    func scheduleNotification(for visit: Visit, with attachment: UNNotificationAttachment? = nil) {
        let message = "Approaching \(visit.firstName ?? "") \(visit.lastName ?? "")"
        
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            print("in app geofence activated")
        } else {
            // Otherwise present a local notification
            
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = message
            notificationContent.sound = UNNotificationSound.default
            if let attachment = attachment {
                notificationContent.attachments = [attachment]
            }
            
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
    func handleEvent(for region: CLRegion!) {
        guard  let visit = self.routePlanProvider.getVisit(forUser: region.identifier) else {
            return
        }
        if let imageUrlString = visit.avatar,  let imageUrl = URL(string: imageUrlString) {
            
            guard let imageData = NSData(contentsOf: imageUrl) else {
                scheduleNotification(for: visit)
                return
            }
            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: imageUrl.lastPathComponent, data: imageData, options: nil) else {
                scheduleNotification(for: visit)
                return
            }
            
            scheduleNotification(for: visit, with: attachment)
        }
      
    }
}

extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL!, options: [])
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL!, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}

