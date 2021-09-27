//
//  MainVC.swift
//  AppliedTest
//
//  Created by Ruslan Sabirov on 9/27/21.
//

import UIKit
import GoogleMaps
import CoreLocation

class MainVC: UIViewController {

    @IBOutlet weak var whiteGradientView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var yourLocationStack: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var whereButton: UIButton!
    @IBOutlet weak var locationBottomConstraint: NSLayoutConstraint!
    
    var centerMapCoordinate: CLLocationCoordinate2D!
    var locationManager = CLLocationManager()
    
    var didMovedOrLocated: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        whereButton.layer.cornerRadius = whereButton.frame.height / 2
        whereButton.titleLabel?.font = Font.montserratSemiBold
        
        setMyLocationDesign()
        
        addBottomGradient()
        
        mapView.animate(toViewingAngle: 45)
        mapView.delegate = self
        
        locationManager.delegate = self
        
        subtitleLabel.font = Font.montserratLight
        locationLabel.font = Font.montserratSemiBold
        
        yourLocationStack.isHidden = true
    }
    
    @objc func reverseGeocode() {
        let geoCoder = GMSGeocoder()
        
        geoCoder.reverseGeocodeCoordinate(centerMapCoordinate) { response, error in
            
            if let location = response?.firstResult() {
                let lines = location.lines! as [String]
                
                dump(lines)

                self.locationLabel.text = lines.joined(separator: ", ")
            }
        }
    }
    
    func showAddress() {
        self.unhideCurrentLocaton()
        locationLabel.text = "Checking..."

        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(reverseGeocode), with: nil, afterDelay: 0.3)
    }

    func unhideCurrentLocaton() {
        self.yourLocationStack.isHidden = false
        self.whereButton.isHidden = true

        UIView.animate(withDuration: 0.0) {
            self.view.layoutIfNeeded()
        }
        
        self.locationBottomConstraint.constant = 114
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }

    @IBAction func locationButtonTapped(_ sender: UIButton) {
        self.didMovedOrLocated = true

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func whereTapped(_ sender: UIButton) {
        
    }
    
    func setMyLocationDesign() {
        let shadowLayer = CAShapeLayer()

        myLocationButton.layer.cornerRadius = myLocationButton.frame.height / 2
        myLocationButton.setTitle("", for: [])
        
        shadowLayer.path = UIBezierPath(roundedRect: myLocationButton.bounds, cornerRadius: myLocationButton.layer.cornerRadius).cgPath
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.fillColor = view.backgroundColor?.cgColor
        shadowLayer.shadowColor = UIColor(red: 0.271, green: 0.357, blue: 0.388, alpha: 0.2).cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 12)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 16
        myLocationButton.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func addBottomGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0, 0.6, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.75)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)

        gradientLayer.frame = whiteGradientView.bounds
        whiteGradientView.layer.mask = gradientLayer
    }
    
}

extension MainVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print("centerMapCoordinate: \(centerMapCoordinate.latitude) \(centerMapCoordinate.longitude)")
        
        if self.didMovedOrLocated {
            self.showAddress()
        }
        
        didMovedOrLocated = true
    }
}

extension MainVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 18)
        
        self.centerMapCoordinate = location.coordinate
        self.showAddress()
        
        self.mapView?.animate(to: camera)

        self.locationManager.stopUpdatingLocation()
    }
}
