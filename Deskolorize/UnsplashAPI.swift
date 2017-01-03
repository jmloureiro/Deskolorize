//
//  UnsplashAPI.swift
//  Deskolorize
//
//  Created by João on 22/12/2016.
//  Copyright © 2016 ZOP. All rights reserved.
//

import Cocoa

struct Photo {
    var id: String
    var url: String
}

class UnsplashAPI: NSObject {
        
    let APPLICATION_ID = Bundle.main.object(forInfoDictionaryKey: "UnsplashApplicationID") as! String
    let BASE_URL = "https://api.unsplash.com/"
        
    func fetchPhotos(featured: Bool, term: String, success: @escaping ([Photo]) -> Void) {
        let session = URLSession.shared
        
        var urlString = "\(BASE_URL)/photos/random?client_id=\(APPLICATION_ID)&count=10&orientation=landscape"
        
        if featured {
            urlString += "&featured"
        }
        
        if (!term.isEmpty) {
            urlString += "&query=\(term)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        }
        
        let url = NSURL(string: urlString)
        
        let task = session.dataTask(with: url! as URL) { data, response, err in
            // first check for a hard error
            if let error = err {
                print("Unsplash API error: \(error)")
            }
            
            // then check the response code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200: // all good!
                    if let photos = self.photosFromJSONData(data: data! as NSData) {
                        success(photos)
                    }
                case 401: // unauthorized
                    print("Unsplash api returned an 'unauthorized' response. Did you set your API key?")
                default:
                    print("Unsplash api returned response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
    
    func photosFromJSONData(data: NSData) -> [Photo]? {
        var photos = [Photo]()
        
        do {
            if NSString(data:data as Data, encoding: String.Encoding.utf8.rawValue) != nil {
                let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as! [AnyObject]
                
                for item in json {
                    var urls = item["urls"] as! [String:AnyObject]
                    
                    let photo = Photo(
                        id: item["id"] as! String,
                        url: urls["full"] as! String
                    )
                    
                    photos.append(photo)
                }
            }
        } catch {
            print(error)
        }
        
        return photos
    }

}
