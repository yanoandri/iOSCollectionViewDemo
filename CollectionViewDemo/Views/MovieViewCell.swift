//
//  MovieViewCell.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 07/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class MovieViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageview_MovieImage: UIImageView!
    @IBOutlet weak var label_badgeLabel: UILabel!
    @IBOutlet weak var label_titleLabel: UILabel!
    @IBOutlet weak var label_subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}
