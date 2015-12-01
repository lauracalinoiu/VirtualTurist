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
        
        let computedBbox = BboxCalculator(latitude: latitude, longitude: longitude).computeCalculation()
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParameterKeys.apiKey:Constants.ApiKey,
            ParameterKeys.method: Methods.search,
            ParameterKeys.format: "json",
            ParameterKeys.nojsoncallback: "1",
            ParameterKeys.extras: "url_m",
            ParameterKeys.bbox: computedBbox]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.search, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                guard let photosFromRequest = JSONResult.objectForKey("photos") as? [String: AnyObject] else{
                    print("Err with photos tag ")
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
                        guard let photoToBeShownUrl = NSURL(string: photoInJSON["url_m"] as! String) else{
                            print("Err with getting photo url")
                            return
                        }
                        
                        if let imageData = NSData(contentsOfURL: photoToBeShownUrl){
                            results.append(imageData)
                        }
                    }
                    completionHandler(result: results, error: nil)
                }
            }
        }
    }
}