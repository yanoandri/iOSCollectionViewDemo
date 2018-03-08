//
//  Movie.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 07/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation

struct  Movie : Codable {
    var id: Int
    var title : String
    var release_date : String
    var poster_path : String
}
