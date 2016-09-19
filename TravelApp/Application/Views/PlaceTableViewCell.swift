//
//  PlaceTableViewCell.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/18/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.titleLabel.layer.shadowColor = UIColor.blackColor().CGColor
        self.titleLabel.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        self.titleLabel.layer.shadowOpacity = 1.0;
        self.titleLabel.layer.shadowRadius = 2.0;
    }
}
