//
//  FlikrViewController.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 01/12/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import UIKit
import MapKit

class FlickrViewController: UIViewController {
    
    var annotation: MKAnnotation!
    @IBOutlet weak var mapSnapshot: UIImageView!
    @IBOutlet weak var picCollection: UICollectionView!
    
    let cellIdentifier = "flickrCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let snapshotter = setupSnapshotter(annotation)
        snapshotter.startWithCompletionHandler({ (snapshot, err) -> Void in
            guard err == nil else {
                print("\(err!.description)")
                return
            }
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let image = snapshot!.image
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.drawAtPoint(CGPoint.zero)
            
            let visibleRect = CGRect(origin: CGPoint.zero, size: image.size)
            
            var point = snapshot!.pointForCoordinate(self.annotation.coordinate)
            if visibleRect.contains(point) {
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
                pin.image?.drawAtPoint(point)
            }
            let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.mapSnapshot.image = compositeImage
        })
        
    }
    
    func setupSnapshotter(annotation: MKAnnotation) -> MKMapSnapshotter{
        let options = MKMapSnapshotOptions()
        options.region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 80000, 20000)
        options.size =  mapSnapshot.bounds.size
        options.scale = UIScreen.mainScreen().scale
        return MKMapSnapshotter(options: options)
    }
    
}
