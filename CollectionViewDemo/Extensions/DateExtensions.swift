//
//  DateExtensions.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 08/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation

extension Date{
    
    func string(format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
