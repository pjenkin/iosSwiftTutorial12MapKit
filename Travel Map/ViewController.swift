//
//  ViewController.swift
//  Travel Map
//
//  Created by Peter Jenkin on 08/04/2019.
//  Copyright © 2019 Peter Jenkin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    
    var chosenLatitude: Double = 0.0     // scope to class to use in various functions
    var chosenLongitude: Double = 0.0      // scope to class to use in various functions
    
    // chosen... var prefix used above - (see 11-88 &c for convention of chosen... selected... variable name correspondence in ViewControllers) - so calling them transmitted... here (cf firstViewController) -  for passing data between ViewControllers
    
    var transmittedTitle = ""
    var transmittedSubtitle = ""
    var transmittedLatitude = 0.0
    var transmittedLongitude = 0.0
    
    var requestCLLocation = CLLocation()    // to use in bespoke annotation
        
    // 1 of 2 - customising annotation, to show new kind of non-standard button bespoke for this app
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //
        
        if annotation is MKUserLocation {
            return nil
        }   // don't do anything if the map is opening for the purpose only of showing the current user location (because directions to current location would be pointless!)
        
        let reuseId = "myAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        // reuse just the 1 annotation view (good for memory resources)
        
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.cyan
            
            
            let button = UIButton(type: .detailDisclosure)      // .detailDisclosure == UIButton.detailDisclosure - detailDisclosure is 'i' in circle
            pinView?.rightCalloutAccessoryView = button         // on right hand side (could've been on left)
        }
        else    // if pinView already existent (already defined, and reused)
        {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    // 2 of 2 - for custom annotation, to pull up driving directions from current location to that location
    //func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //<#code#>
    //} // had to auto-complete by calloutAccess..... 
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if transmittedLatitude != 0 && transmittedLongitude != 0
        {
            self.requestCLLocation = CLLocation(latitude: transmittedLatitude, longitude: transmittedLongitude)    // to use in reverse geolocation below
        }
        
        //CLGeocoder().reverseGeocodeLocation(<#T##location: CLLocation##CLLocation#>, completionHandler: <#T##CLGeocodeCompletionHandler##CLGeocodeCompletionHandler##([CLPlacemark]?, Error?) -> Void#>)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation)
        {
            (placemarks, error) in
            if let placemark = placemarks
            {
                if placemark.count > 0        // if successfully reverse geo-coded
                {
                    let newPlaceMark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlaceMark)
                    item.name = self.transmittedTitle
                    
                    // launch a screen showing travel directions to/fro
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
    
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        
        newLocation.setValue(nameText.text, forKey: "title")
        newLocation.setValue(commentText.text, forKey: "subtitle")
        newLocation.setValue(chosenLatitude, forKey: "latitude")
        newLocation.setValue(chosenLongitude, forKey: "longitude")
        
        
        
        do {
            try context.save()
            print("saved data in context")
        } catch{
            print("Error in saving to context")
        }
        
        // look out for /observe this notification in other view controller
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newLocationRecorded"), object: nil)
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   // NB battery drain with accuracy
        locationManager.requestWhenInUseAuthorization() // how often to as for permission (cf adding Privacy-Location when in use’ in Info.plist - )
        locationManager.startUpdatingLocation() // NB function didUpdateLocation function
        
        // declare gesture recognition
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 3    // 3 seconds press
        mapView.addGestureRecognizer(recognizer)
        
        
        if transmittedTitle != ""       // if being transmitted/passed data from another View Controller
        {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: self.transmittedLatitude, longitude: self.transmittedLongitude)
            annotation.coordinate = coordinate
            annotation.title = self.transmittedTitle
            annotation.subtitle = self.transmittedSubtitle
            
            self.mapView.addAnnotation(annotation)
            
            // update text field values displayed
            self.nameText.text = self.transmittedTitle
            self.commentText.text = self.transmittedSubtitle

        }
        
    }
    
    // function to handle location udate NB parameters
    //func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // code
    //}
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let location = CLLocationCoordinate2D(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>)
        // NB locations is a parameter in this 'handler' for updated location on device
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // zoom level (standard 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer)      // bespoke handler function
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            // let chosenCoordinates = self.mapView.convert(<#T##point: CGPoint##CGPoint#>, toCoordinateFrom: <#T##UIView?#>)
            let chosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            self.chosenLatitude = chosenCoordinates.latitude
            self.chosenLongitude = chosenCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

