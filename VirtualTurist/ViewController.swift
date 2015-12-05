//
//  ViewController.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 30/11/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var messageLabel: UILabel!
    
    let deletePinsMessage = "Tap on pins to delete them"
    let addPinsMessage = "Long press for adding new pin"
    
    var contextPins: [Pin]!
    lazy var sharedContext: NSManagedObjectContext  = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        mapView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addPins:")
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
     
        contextPins = fetchAllPins()
        setUpAddPinsMessage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for pin in contextPins{
            addAnnotationForLocation(pin)
        }
    }
    
    func fetchAllPins() -> [Pin]{
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: sharedContext)
        
        fetchRequest.entity = entity
        
        var results: [AnyObject]!
        do{
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch {
            results = nil
            print("\(error)")
        }
        return results as! [Pin]
    }
    
    func addAnnotationForLocation(pin: Pin){
        let annot = MKPointAnnotation()
        annot.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
        mapView.addAnnotation(annot)
    }
    
    
    func setUpAddPinsMessage(){
        messageLabel.text = addPinsMessage
        messageLabel.backgroundColor = UIColor.darkGrayColor()
    }
    
    func setUpDeletePinsMessage(){
        messageLabel.text = deletePinsMessage
        messageLabel.backgroundColor = UIColor.redColor()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            setUpDeletePinsMessage()
        } else {
            setUpAddPinsMessage()
        }
        
    }
    
    func addPins(gestureRescognizer: UIGestureRecognizer){
        if !self.editing {
            if gestureRescognizer.state != UIGestureRecognizerState.Began{
                return
            }
            
            let point = gestureRescognizer.locationInView(mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
            
            let annot = MKPointAnnotation()
            annot.coordinate = coordinate
            
            mapView.addAnnotation(annot)
            
            contextPins.append(Pin(dictionary: [Pin.Keys.lat: annot.coordinate.latitude,
                Pin.Keys.lon: annot.coordinate.longitude], context: sharedContext))
            saveContext()
        }
    }
    
    func saveContext(){
        do{
            try sharedContext.save()
        } catch {
            print("err in save \(error)")
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if self.editing {
            let point = view.annotation
            mapView.removeAnnotation(point!)
            
            let pin = contextPins.filter{$0.lat == point?.coordinate.latitude && $0.lon == point?.coordinate.longitude}.first
            if let unwrappedPin = pin {
                contextPins.removeAtIndex(contextPins.indexOf(unwrappedPin)!)
                sharedContext.deleteObject(unwrappedPin)
            }
            saveContext()
            
        } else {
            performSegueWithIdentifier("clickOnPin", sender: view)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "clickOnPin" {
            let vc = segue.destinationViewController as! FlickrViewController
            vc.annotation = (sender as! MKAnnotationView).annotation
        }
    }
    
}

