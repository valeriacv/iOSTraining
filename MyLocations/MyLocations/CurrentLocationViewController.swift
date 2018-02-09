//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Vale Calderon  on 4/4/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

import UIKit

import CoreLocation
import CoreData
import QuartzCore

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    let locationManager = CLLocationManager()
    
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    //Reverse Geocoding variables ---- Reverse geocode converts latitude and longitude data y readable addresses
    let geocoder = CLGeocoder() //Object that does the geocoding
    var placemark: CLPlacemark? //Contains the result address
    var performingReverseGeocoding = false //True when the geocoding is been perform
    var lastGeocodingError: Error? //Any error that could occur during the geocoding
    
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext! //Data model context
    
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation),
                         for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Prepara the change from the current location screen to the tag location screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
        
            //Pass the current coordinates, the placemark of the location and the managed object context to the LocantionsDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    //Action from the Get Location Button
    @IBAction func getLocation() {
        //CLLocationManager is and object that verifies if the app has access to the location of the devices
        let authStatus = CLLocationManager.authorizationStatus()
        
        //If the status has not been set, it shows an alert asking for authorization
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        //If there is no authorization, it shows an alert saying that the app can't access the devices current location
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        //If it has authorization it hides the main screen logo
        if logoVisible {
            hideLogoView()
        }
        
        //if the Location API is still searching for and update location, stop it
        if updatingLocation {
            stopLocationManager()
            
        //Sets the data of the location to nill, and start searching for the current location
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
    }
    
    //Show alert so the user knows that the location services are disable for the app, and can't get the coordinates of the current device
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //Update the screen labels with the information that the process of getting the location gives
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as? NSError {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                showLogoView()
            }
            
            messageLabel.text = statusMessage
            
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    
    //If the location manager is still searching for a location puts a spinner in the screen and puts visible a stop button (stop seacrhing for a location)
    //Else sets the get my location button and remove the spinner.
    func configureGetButton() {
        let spinnerTag = 1000
        
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    //Starts searching for the current location
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            //Sets a timer, if the time searching of the location is greater than 60 seconds, it shows an error.
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                         selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    
    //Stop the location manager from continue searching for a location
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    //After 60 seconds of searching for a Location, didTimeOut is call, if there is no location registes, it shows and error.
    func didTimeOut() {
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    //Name: locationManager(didFailWithError)
    //Location manager couldn't get a location, shows an error.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    //Name: locationManager(didUpdateLocations)
    //Location manager could get at least one location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Sets the last updated location the location manager got.
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        //If the location was taken 5 seconds ago or more, the locations get ignored
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        //Horizontal Accuracy determines the acuracy of the location, but if they are less than 0, are invalid.
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        //Calculates the distance of the new location and the last one, to see if is still improving
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        //Checks if the last location has a greater accuracy than the new one, a larger accuracy value, means less accuracy
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            manageValidLocation(newLocation: newLocation, distance: distance)
            
        //If the new location and the last location doesn't have a significant difference and the time between the reading of the both is greater than 10, it stops the location manager, because the probabilities to get a more accurate location is almost none.
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    //newLocation is a valid location, so it clear all error, save the new location and display in the screen the data for the new locations
    private func manageValidLocation(newLocation: CLLocation, distance: CLLocationDistance){
        lastLocationError = nil //Clears all errors
        location = newLocation //Save the new location
        updateLabels()  //Update the labels
        
        //When the accuracy is equal or better than the desiredAccuracy(10 meters)
        //Stop the manager from continue updating
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("*** We're done!")
            stopLocationManager()
            configureGetButton()
            
            //If there is a location that is performing the geocoding, but is not the last one, it puts the propertie of performingReverseGeocoding to false to force the geocoding to the last location
            if distance > 0 {
                performingReverseGeocoding = false
            }
        }
        doGeocodingProcess(pNewLocation: newLocation)
    }
    
    
    
    //The geocoding process converts a latitude and logintude to a readable address
    private func doGeocodingProcess(pNewLocation: CLLocation){
        if !performingReverseGeocoding {
            print("*** Going to geocode")
            
            performingReverseGeocoding = true
            
            geocoder.reverseGeocodeLocation(pNewLocation, completionHandler: {
                placemarks, error in
                
                print("*** Found placemarks: \(String(describing: placemarks)), error: \(String(describing: error))")
                
                self.lastGeocodingError = error
                if error == nil, let p = placemarks, !p.isEmpty {
                    //If there was no error, placemark should not be nil,  it could be more than one placemark, so it takes the last one
                    //if there was an erro, the placemark is going to be set to nil.
                    if self.placemark == nil {
                        print("FIRST TIME!")
                    }
                    self.placemark = p.last!
                } else {
                    self.placemark = nil
                }
                //The reverse geocoding finish, so set the variable to false, and update the labels with the placemark that it got.
                self.performingReverseGeocoding = false
                self.updateLabels()
            })
        }
    }
    
    
    
    
    // MARK: - Logo View
    
    func showLogoView() {
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        if !logoVisible { return }
        
        logoVisible = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        let centerX = view.bounds.midX
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint:
            CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint:
            CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
  
}




