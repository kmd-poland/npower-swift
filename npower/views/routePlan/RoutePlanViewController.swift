import ViewModelOwners
import RxSwift
import UIKit
import Mapbox
import FloatingPanel
import Kingfisher
import PromiseKit

class RoutePlanMapView: MGLMapView {
}

class RoutePlanViewController: UIViewController, MGLMapViewDelegate, NonReusableViewModelOwner {

    @IBOutlet weak var mapView: RoutePlanMapView!
    var panelController: FloatingPanelController?
    private let avatarProvider: AvatarImageProviderProtocol
    private var routeLine: MGLPolyline?

    init(_ avatarProvider: AvatarImageProviderProtocol) {
        self.avatarProvider = avatarProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.styleURL = MGLStyle.streetsStyleURL
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.zoomLevel = 12

        self.panelController = {
            let fpc = FloatingPanelController()
            fpc.surfaceView.backgroundColor = .clear
            fpc.surfaceView.cornerRadius = 9
            fpc.addPanel(toParent: self)
            return fpc
        }()
    }

    func didSetViewModel(_ viewModel: RoutePlanViewModelProtocol, disposeBag: DisposeBag) {
        viewModel
                .visits
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] (value) in
                    self.displayAnnotations(for: value)
                })
                .disposed(by: disposeBag)

        viewModel
                .currentRoute
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] route in
                    if let oldRoute = self.routeLine {
                        self.mapView.removeAnnotation(oldRoute)
                    }
                    if var routeCoordinates = route.coordinates {
                        let routeLine = MGLPolyline(coordinates: routeCoordinates, count: route.coordinateCount)

                        // Add the polyline to the map and fit the viewport to the polyline.
                        self.mapView.addAnnotation(routeLine)
                   
                        self.mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding:  UIEdgeInsets(top: 30, left: 30, bottom: 300, right: 30), animated: true)
                        self.routeLine = routeLine
                    }
                })
                .disposed(by: disposeBag)
    }

    func displayAnnotations(for visits: [Visit]) {
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }

        var annotationsList = [MGLPointAnnotation]()

        for visit in visits {
            let coord = CLLocationCoordinate2D(latitude: visit.coordinates[1], longitude: visit.coordinates[0])
            let name = "\(visit.firstName ?? "") \(visit.lastName ?? "")"
            let annotation = AvatarAnnotation()
            annotation.coordinate = coord
            annotation.title = name

            if let url = visit.avatar, let avatarUrl = URL(string: url) {
                annotation.avatarImage = avatarUrl
            }
            annotationsList.append(annotation)
        }

        self.mapView.addAnnotations(annotationsList)

        var coordinates = annotationsList.map { annotation in
            annotation.coordinate
        }

        self.mapView.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count),
                edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 300, right: 30),
                animated: true)
    }


    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let annotation = annotation as? AvatarAnnotation, let avatarUrl = annotation.avatarImage {
            var image = mapView.dequeueReusableAnnotationImage(withIdentifier: avatarUrl.description)
            if image == nil {
                image = MGLAnnotationImage(image: UIImage(named: "placeholder")!, reuseIdentifier: avatarUrl.description)

                avatarProvider.getAvatar(for: avatarUrl, withSize: 60)
                        .done { img in
                            image?.image = img
                        }.catch {
                            print($0)
                        }
            }
            return image
        }
        return nil
    }
}


class AvatarAnnotation: MGLPointAnnotation {
    var avatarImage: URL?
}
