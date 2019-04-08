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
    
    
    var chosenLatitude: Double = 0      // scope to class to use in various functions
    var chosenLongitude: Double = 0      // scope to class to use in various functions
    
    
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

