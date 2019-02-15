//
//  CustomSuggestedChordCell.swift
//  ChordSuggester
//
//  Created by Jackson Kurtz on 5/28/18.
//  Copyright © 2018 Jackson Kurtz. All rights reserved.
//

import Foundation

import UIKit

class CustomSuggestedChordCell: UICollectionViewCell {
    @IBOutlet weak var numeralLabel: UILabel!
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    override init( frame: CGRect ) {
        super.init(frame: frame)
        initCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder)
        initCell()
    }
    
    private func initCell() {
        
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        //self.contentView.layer.backgroundColor =  UIColor.white.cgColor
        //self.contentView.clipsToBounds = true
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize( width:0, height:2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        //self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
}
