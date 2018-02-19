//
//  HomeTableViewCell.swift
//  No Broker
//
//  Created by Subhadeep Pal on 18/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var propertyNameLabel: UILabel!
    @IBOutlet weak var propertyLocationLabel: UILabel!
    @IBOutlet weak var propertyImageView: UIImageView!
    @IBOutlet weak var rentAmountLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var featuredLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
