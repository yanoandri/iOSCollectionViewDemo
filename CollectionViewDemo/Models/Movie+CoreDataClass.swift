//
//  Movie+CoreDataClass.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 08/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Movie)
public class Movie: NSManagedObject {
    
    class func movie(with data : [String:Any], in context : NSManagedObjectContext)->Movie{
        var movie: Movie!
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let movieId = data["id"] as? Int32 ?? 0
        request.predicate = NSPredicate(format: "movieId = \(movieId)")
        
        var movies: [Movie] = []
        do{movies = try context.fetch(request)}
        catch{print(error.localizedDescription)}
        
        if movies.count > 0{
            movie = movies[0]
        }else{
            movie = Movie(context: context)
            movie.movieId = data["id"] as? Int32 ?? 0
        }
        
        movie.title = data["title"] as? String
        movie.posterPath = data["poster_path"] as? String
        movie.backdropPath = data["backdrop_path"] as? String
        movie.overview = data["overview"] as? String
        movie.releaseDate = (data["release_date"] as? String)?.date(format: "yyyy-MM-dd")
        
        return movie
    }
    
    class func movie(in context: NSManagedObjectContext) -> Movie{
        var movie: Movie!
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor.init(key: "releaseDate", ascending: true),
                                   NSSortDescriptor.init(key: "title", ascending: true)
        ]
        var movies: [Movie] = []
        
        do{movies = try context.fetch(request)}
        catch{print(error.localizedDescription)}
        
        return movie
    }
}
