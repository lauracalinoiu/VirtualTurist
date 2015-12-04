//
//  ConstantsFlickrAPI.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 01/12/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import Foundation
extension FlickrAPIClient{
    
    // MARK: Constants
    struct Constants {
        // MARK: API Key
        static let ApiKey : String = "5ebf547a17baa59faeaf70d96093e9d9"
        
        // MARK: URLs
        static let BaseURL : String = "https://api.flickr.com/services/rest/"
    }
    
    // MARK: Methods
    struct Methods {
        // MARK: Account
        static let search = "flickr.photos.search"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let apiKey = "api_key"
        static let method = "method"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
        static let extras = "extras"
        static let bbox = "bbox"
        static let lat = "lat"
        static let lon = "lon"
        static let in_gallery = "in_gallery"
    }
}