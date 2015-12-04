//
//  FlikrViewController.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 01/12/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import UIKit
import MapKit

class FlickrViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var annotation: MKAnnotation!
    @IBOutlet weak var mapSnapshot: UIImageView!
    @IBOutlet weak var picCollection: UICollectionView!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let cellIdentifier = "imgCell"
    var snapshotter: MKMapSnapshotter!
    
    var imagesData: [NSData] = [NSData]()
    var selectedCells: [NSData] = [NSData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snapshotter = setupSnapshotter(annotation)
        putSnapshotterToWork()
        
        picCollection.delegate = self
        picCollection.dataSource = self
        picCollection.allowsMultipleSelection = true
        
        loadButton.hidden = false
        removeButton.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getImagesDataFromFlickr()
    }
    
    func getImagesDataFromFlickr() -> Void {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        loadButton.hidden = true
        
        FlickrAPIClient.sharedInstance().getPhotosUsingLatAndLong(annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { results, error in
            
            guard error == nil else {
                print("\(error!.description)")
                return
            }
            
            if let imagesData = results {
                self.imagesData = imagesData
                dispatch_async(dispatch_get_main_queue()) {
                    self.picCollection.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.loadButton.hidden = false
                }
            } else {
                print(error)
            }
        }
    }
    
    func putSnapshotterToWork(){
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ImgCell
        cell.imageView.image = UIImage(data: imagesData[indexPath.row])
        cell.selected = false
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesData.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        loadButton.hidden = true
        removeButton.hidden = false
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ImgCell
        cell.imageView.alpha = 0.3
        
        selectedCells.append(imagesData[indexPath.row])
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ImgCell
        cell.imageView.alpha = 1
        
        let index = selectedCells.indexOf(imagesData[indexPath.row])
        selectedCells.removeAtIndex(index!)
    }
    @IBAction func loadButtonHit(sender: UIButton) {
        getImagesDataFromFlickr()
    }
    
    @IBAction func removeButtonHit(sender: UIButton) {
        for image in imagesData{
            if selectedCells.contains(image){
                imagesData.removeAtIndex(imagesData.indexOf(image)!)
            }
        }
     
        picCollection.reloadData()
    }
}
