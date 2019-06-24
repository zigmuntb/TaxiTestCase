//
//  ViewController.swift
//  TaxiTask
//
//  Created by Arsenkin Bogdan on 6/24/19.
//  Copyright © 2019 Arsenkin Bogdan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate {

	@IBOutlet weak var locationName: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	
	let locationManager = CLLocationManager()
	let locationDataModel = LocationDataModel()
	
	let regionInMeters: Double = 1000
	var longitude : Double = 0
	var latitude : Double = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationServicesCheck()
		latitude = mapView.centerCoordinate.latitude
		longitude = mapView.centerCoordinate.longitude
		
		getLocationData(url: "https://nominatim.openstreetmap.org/reverse.php?format=json&lat=\(latitude)&lon=\(longitude)")
	}

	func setupLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
	func locationServicesCheck() {
		if CLLocationManager.locationServicesEnabled() {
			setupLocationManager()
			locationAutorizationCheck()
		} else {
			let alert = UIAlertController(title: "Error", message: "Please turn on geo location", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func getLocationData(url: String) {
		
		Alamofire.request(url, method: .get).responseJSON {
			responce in
			
			if responce.result.isSuccess {
				print("Success! Got the location data!")
				
				let locationJSON : JSON = JSON(responce.result.value!)
				self.updateLocationData(json: locationJSON)
			}
			else {
				print("Error \(String(describing: responce.result.error))")
				self.locationName.text = "Connection Issues"
			}
		}
	}
	
	func updateLocationData(json:JSON) {
		if let locationResult = json["display_name"].string {
			locationDataModel.displayName = locationResult
			updateUIWithLocationData()
		} else {
			locationName.text = "Unavailable location"
		}
	}
	
	func updateUIWithLocationData() {
		locationName.text = locationDataModel.displayName
	}
	
	func zoomInOnUserLocation() {
		guard let location = locationManager.location?.coordinate else { return }
		let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
		mapView.setRegion(region, animated: true)
	}
	
	func locationAutorizationCheck() {
		switch CLLocationManager.authorizationStatus() {
		case .authorizedAlways:
			break
		case .authorizedWhenInUse:
			zoomInOnUserLocation()
			break
		case .denied:
			break
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .restricted:
			break
		@unknown default:
			fatalError()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		return
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		return
	}
}

