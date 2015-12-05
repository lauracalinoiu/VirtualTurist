//
//  FlikrViewController.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 01/12/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlickrViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var pin: Pin!
    @IBOutlet weak var mapSnapshot: UIImageView!
    @IBOutlet weak var picCollection: UICollectionView!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let cellIdentifier = "imgCell"
    var snapshotter: MKMapSnapshotter!
    
    lazy var sharedContext: NSManagedObjectContext  = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var selectedIndexes: [Int] = [Int](){
        didSet{
            picCollection.reloadData()
            
            if selectedIndexes.count == 0{
                loadButton.hidden = false
                removeButton.hidden = true
            } else {
                loadButton.hidden = true
                removeButton.hidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snapshotter = setupSnapshotter()
        putSnapshotterToWork()
        
        picCollection.delegate = self
        picCollection.dataSource = self
        picCollection.allowsMultipleSelection = true
        
        loadButton.hidden = false
        removeButton.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getImagesDataFromFlickr() -> Void {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        loadButton.hidden = true
        
        FlickrAPIClient.sharedInstance().getPhotosUsingLatAndLong(pin.lat, longitude: pin.lon) { results, error in
            
            guard error == nil else {
                print("\(error!.description)")
                return
            }
            
            if let imagesUrls = results {
                
                for imageUrl in imagesUrls{
                    let pic = Pic(dictionary: [Pic.Keys.url: imageUrl], context: self.sharedContext)
                    pic.pin = self.pin
                }
                
                self.saveContext()
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
            
            var point = snapshot!.pointForCoordinate(CLLocationCoordinate2D(latitude: self.pin.lat, longitude: self.pin.lon))
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
    
    func setupSnapshotter() -> MKMapSnapshotter{
        let options = MKMapSnapshotOptions()
        options.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon), 80000, 20000)
        options.size =  mapSnapshot.bounds.size
        options.scale = UIScreen.mainScreen().scale
        return MKMapSnapshotter(options: options)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ImgCell
        
        let pictures = pin.pics
        let pic = pictures.allObjects[indexPath.row] as! Pic
        let imageURL = NSURL(string: pic.url)
        if let imageData = NSData(contentsOfURL: imageURL!){
            cell.imageView.image = UIImage(data: imageData)
        }
        
        if selectedIndexes.contains(indexPath.row){
            cell.imageView.alpha = 0.3
        } else {
            cell.imageView.alpha = 1
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.pics.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if selectedIndexes.contains(indexPath.row){
            selectedIndexes.removeAtIndex(selectedIndexes.indexOf(indexPath.row)!)
        } else {
            selectedIndexes.append(indexPath.row)
        }
        
        print(selectedIndexes.count)
    }
  
    @IBAction func loadButtonHit(sender: UIButton) {
        getImagesDataFromFlickr()
    }
    
    @IBAction func removeButtonHit(sender: UIButton) {
        selectedIndexes.sortInPlace(){$0>$1}
        for index in selectedIndexes {
            let pic = pin.pics.allObjects[index] as! Pic
            sharedContext.deleteObject(pic)
        }
        saveContext()
        selectedIndexes = [Int]()
    }
    func saveContext(){
        do{
            try sharedContext.save()
        } catch {
            print("err in save \(error)")
        }
    }
}
