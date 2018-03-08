//
//  MoviePosterHelper.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 08/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class MoviePosterHelper: NSObject {
    typealias Completion<T> = (T?, Error?) -> Void
    var imageCache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
    let kTmdbAPIkey = "9548fa0910e2897f79dfdc19e0b2e9a0"
    
    class var shared: MoviePosterHelper{
        struct Static{
            static let instance: MoviePosterHelper = MoviePosterHelper()
        }
        return Static.instance
    }
    
    
    func downloadImage(with urlString: String, completion: @escaping Completion<UIImage>){
        if let url = URL(string: urlString){
            if let image = imageCache.object(forKey: NSString(string: urlString)){
                completion(image, nil)
            }else{
                DispatchQueue.global().async {
                    if let data = try? Data.init(contentsOf: url), let image = UIImage.init(data: data){
                        self.imageCache.setObject(image, forKey: NSString(string: urlString))
                        DispatchQueue.main.async {
                            completion(image, nil)
                        }
                    }else{
                        let error = NSError(domain: "MOVIELIST", code: 0, userInfo: [NSLocalizedDescriptionKey: "data is not valid format"])
                        completion(nil,error)
                    }
                }
            }
        }else{
            let error = NSError(domain: "MOVIELIST", code: 0, userInfo: [NSLocalizedDescriptionKey: "connection error"])
            completion(nil, error)
        }
    }
    
    
    func loadMovie(page: Int = 1,completion : @escaping Completion<MoviesResponse>){
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(kTmdbAPIkey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)&primary_release_year=2018"
        let request = URLRequest(url: URL.init(string: urlString)!)
        let session = URLSession.shared
        
        session.dataTask(with: request){
            (data,response, error) in
            
            DispatchQueue.main.async {
                if let data = data{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        let response = MoviesResponse(data: json)
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.saveContext()
                        
                        completion(response, error)
                    }catch{
                        completion(nil, error)
                    }
                }else{
                    completion(nil, error)
                }
            }}.resume()
    }
}
