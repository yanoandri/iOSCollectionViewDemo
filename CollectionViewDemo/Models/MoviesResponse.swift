//
//  MoviesResponse.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 07/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation
import UIKit

struct MoviesResponse {
    var page: Int = 0
    var total_results: Int = 0
    var total_pages: Int = 0
    var results: [Movie]
    
    init(data: [String:Any]){
        page = data["page"] as? Int ?? 0
        total_results = data["total_results"] as? Int ?? 0
        total_pages = data["total_pages"] as? Int ?? 0
        results = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        if let r = data["results"] as? [[String: Any]]{
            for d in r{
                let movie = Movie.movie(with: d, in: context)
                results.append(movie)
            }
        }
    }
    
}
