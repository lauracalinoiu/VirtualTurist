//
//  ViewController.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 30/11/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var messageLabel: UILabel!
    
    let deletePinsMessage = "Tap on pins to delete them"
    let addPinsMessage = "Long press for adding new pin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        mapView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addPins:")
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
        
        setUpAddPinsMessage()
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
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if self.editing {
            let point = view.annotation
            mapView.removeAnnotation(point!)
        } else {
            performSegueWithIdentifier("clickOnPin", sender: view)
        }
    }
    
    func setupSnapshotter() -> MKMapSnapshotter{
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.size = mapView.frame.size
        options.scale = UIScreen.mainScreen().scale
        return MKMapSnapshotter()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "clickOnPin" {
            let vc = segue.destinationViewController as! FlickrViewController
            vc.annotation = (sender as! MKAnnotationView).annotation
            let snapshotter = setupSnapshotter()
            snapshotter.startWithCompletionHandler({ (snapshot, err) -> Void in
                guard err == nil else {
                    return
                }
                vc.mapSnapshot.image = snapshot!.image
            })
        }
    }
    
}

