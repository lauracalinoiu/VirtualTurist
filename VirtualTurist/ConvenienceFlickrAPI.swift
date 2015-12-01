//
//  ConvenienceFlickrAPI.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 01/12/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import Foundation
import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension FlickrAPIClient {
    // MARK: GET Convenience Methods
    
    func getPhotosUsingLatAndLong(latitude: Double, longitude: Double, completionHandler: (result: [NSData]?, error: NSError?) -> Void) {
        
        //let computedBbox = BboxCalculator(latitude: latitude, longitude: longitude).computeCalculation()
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters: [String: AnyObject] = [ParameterKeys.method: Methods.search,
            ParameterKeys.format: "json",
            ParameterKeys.nojsoncallback: "1",
            ParameterKeys.extras: "url_m",
            ParameterKeys.lat: latitude,
            ParameterKeys.lon: longitude]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.search, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                
                /* GUARD: Did Flickr return an error? */
                guard let stat = JSONResult["stat"] as? String where stat == "ok" else {
                    print("Flickr API returned an error. See error code and message in \(JSONResult)")
                    return
                }
                
                print("------------\(JSONResult)")
                guard let photosFromRequest = JSONResult["photos"] as? NSDictionary else{
                    print("XXX   Err with photos tag ")
                    return
                }
                
                guard let howManyPhotos = Int(photosFromRequest["total"] as! String) else{
                    print("Err with getting total tag")
                    return
                }
                
                if howManyPhotos != 0{
                    guard let photos = photosFromRequest["photo"] as? [[String:AnyObject]] else{
                        print("Err with getting photo tag")
                        return
                    }
                    
                    var results: [NSData] = [NSData]()
                    for photoInJSON in photos{
                        guard let imageUrlString = photoInJSON["url_m"] as? String else {
                            print("Cannot find key 'url_m' in \(photoInJSON)")
                            return
                        }
                        let imageURL = NSURL(string: imageUrlString)
                        
                        if let imageData = NSData(contentsOfURL: imageURL!){
                            results.append(imageData)
                        }
                    }
                    completionHandler(result: results, error: nil)
                }
            }
        }
    }
}