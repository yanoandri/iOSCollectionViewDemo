//
//  Movie+CoreDataProperties.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 08/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var movieId: Int32
    @NSManaged public var title: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var overview: String?

}
