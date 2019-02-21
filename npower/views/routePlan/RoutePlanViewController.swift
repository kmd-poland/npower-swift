//
//  RoutePlanViewController.swift
//  npower
//
//  Created by Czechowski.Maciej MCZ on 21/02/2019.
//  Copyright © 2019 kmdpoland. All rights reserved.
//

import UIKit
import Mapbox

class RoutePlanMapView: MGLMapView {}

class RoutePlanViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var mapView: RoutePlanMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.styleURL = MGLStyle.satelliteStyleURL
        mapView.delegate = self
        mapView.showsUserLocation = true
        // Do any additional setup after loading the view.
    }

    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
