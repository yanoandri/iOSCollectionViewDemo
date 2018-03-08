//
//  StringExtensions.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 08/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation

extension String{
    
    func date(format: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: self) ?? Date(timeIntervalSince1970: 0)
    }
}
