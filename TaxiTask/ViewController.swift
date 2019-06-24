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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationServicesCheck()
		
		
		
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
			locationManager.startUpdatingLocation()
			break
		case .denied:
			showAlert()
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .restricted:
			showAlert()
		@unknown default:
			fatalError()
		}
	}
	
	//MARK: - Location delegate methods
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
		mapView.setRegion(region, animated: true)
		getLocationData(url: "https://nominatim.openstreetmap.org/reverse.php?format=json&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)")
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		locationAutorizationCheck()
	}
	
	private func showAlert() {
		let alertController = UIAlertController (title: "Attention", message: "Please go to settings and turn on location sevices.", preferredStyle: .alert)
		
		let settingsAction = UIAlertAction(title: "Ok", style: .default) { _ in
			
			guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
				return
			}
			
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl)
			}
		}
		alertController.addAction(settingsAction)
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}
}

