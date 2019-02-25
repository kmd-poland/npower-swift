import ViewModelOwners
import RxSwift
import UIKit
import Mapbox
import FloatingPanel

class RoutePlanMapView: MGLMapView {
}

class RoutePlanViewController: UIViewController, MGLMapViewDelegate, NonReusableViewModelOwner {

    @IBOutlet weak var mapView: RoutePlanMapView!
    var panelController: FloatingPanelController?
    var panelDelegate: FloatingPanelControllerDelegate?
    //private var panelConfigurationProvider: PanelConfigurationProvider?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.styleURL = MGLStyle.streetsStyleURL
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.zoomLevel = 3
        
        self.panelController = {
            let fpc = FloatingPanelController()
            fpc.surfaceView.backgroundColor = .clear
            fpc.surfaceView.cornerRadius = 9
            fpc.addPanel(toParent: self)
            return fpc
        }()
    }

    func didSetViewModel(_ viewModel: RoutePlanViewModelProtocol, disposeBag: DisposeBag) {
//        viewModel
//                .visits
//                .subscribe((onNext: { [unowned self] (value) in
//                    self.titleLabel.text = value
//                })
//                .disposed(by: disposeBag)
    }


    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }


}


