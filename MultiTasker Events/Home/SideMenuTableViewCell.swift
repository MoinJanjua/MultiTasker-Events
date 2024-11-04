//
//  SideMenuTableViewCell.swift
//  Flip & Bet
//
//  Created by Moin Janjua on 12/08/2024.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var sMenuImgs: UIImageView!
    @IBOutlet weak var sidemenu_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set up shadow properties
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 4.0
        contentView.layer.masksToBounds = false
        
        // Set background opacity
        contentView.alpha = 1.5 // Adjust opacity as needed
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
