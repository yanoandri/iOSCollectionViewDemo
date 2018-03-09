//
//  Movie+CoreDataProperties.swift
//  
//
//  Created by Developer 1 on 09/03/18.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var backdropPath: String?
    @NSManaged public var movieId: Int32
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var favorited: Bool

}
