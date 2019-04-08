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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
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
            
            let annotation = MKPointAnnotation()
            // let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            // annotation.canShowCallOut = true
/*
            // below bodged from recommendation https://www.hackingwithswift.com/example-code/location/how-to-add-annotations-to-mkmapview-using-mkpointannotation-and-mkpinannotationview (trying to fix title, which was my mistake)
            let identifier = "Annotation"
            
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil
            {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                print("set canshowcallout")
            }
            else
            {
                annotationView!.annotation = annotation
            }
*/
            // above bodged from recommendation https://www.hackingwithswift.com/example-code/location/how-to-add-annotations-to-mkmapview-using-mkpointannotation-and-mkpinannotationview (trying to fix title, which was my mistake)
            
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

